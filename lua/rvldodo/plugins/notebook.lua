-- Jupyter notebooks in Neovim, replacing the Cursor/VS Code notebook UI.
--
-- Three plugins, one job each:
--   jupytext.nvim  – opens *.ipynb as a plain python buffer (hydrogen style:
--                    `# %%` cell markers, magics like `!ollama pull` kept as-is)
--                    and writes it back to .ipynb on save. Because the buffer is
--                    real python, pyright/ruff/conform attach unchanged.
--   molten-nvim    – runs cells against a Jupyter kernel and shows output
--                    inline (virtual text under the cell, float on <leader>jo).
--   image.nvim     – renders plots/images in the terminal (kitty graphics
--                    protocol; tmux needs `allow-passthrough on`, already set).
--
-- Host-side python deps (pynvim, jupyter_client, jupytext, nbformat, ...) live
-- in the dedicated neovim venv set in core/options.lua — NOT in any project
-- venv. The kernel itself runs in the project's venv: the first <leader>ji /
-- <leader>jj in a project installs ipykernel there and registers a kernelspec
-- named after the project root (see resolve_kernel). Projects without a venv
-- can fall back to the global `python3` kernel, which comes from
--   uv tool install jupyter-core --with jupyterlab --with notebook --with ipykernel ...
-- (that also puts `jupyter lab` / `jupyter notebook` on PATH).
return {
   {
      "GCBallesteros/jupytext.nvim",
      -- Must be loaded before the first *.ipynb BufReadCmd fires, so no lazy.
      lazy = false,
      init = function()
         -- jupytext.nvim keeps a `foo.py` sidecar next to `foo.ipynb` while the
         -- buffer is open and deletes it on BufUnload. If nvim dies first, the
         -- sidecar survives and the plugin silently loads *it* next time,
         -- instead of the notebook — stale after a `git pull`. Registered here
         -- (before the plugin's own BufReadCmd) so it runs first.
         vim.api.nvim_create_autocmd("BufReadCmd", {
            pattern = "*.ipynb",
            group = vim.api.nvim_create_augroup("JupytextStaleSidecar", { clear = true }),
            callback = function(ev)
               local nb = ev.match
               local sidecar = nb:gsub("%.ipynb$", ".py")
               -- jupytext.nvim errors on a notebook that doesn't exist yet, so
               -- `nvim new.ipynb` would fail. Seed an empty nbformat-4 file first.
               if vim.fn.filereadable(nb) == 0 and vim.fn.filereadable(sidecar) == 0 then
                  vim.fn.mkdir(vim.fs.dirname(nb), "p")
                  vim.fn.writefile({
                     vim.json.encode({
                        cells = {},
                        metadata = {
                           kernelspec = { display_name = "Python 3", language = "python", name = "python3" },
                           language_info = { name = "python" },
                        },
                        nbformat = 4,
                        nbformat_minor = 5,
                     }),
                  }, nb)
                  vim.notify("Created empty notebook " .. vim.fs.basename(nb), vim.log.levels.INFO)
                  return
               end
               if vim.fn.filereadable(sidecar) == 0 then
                  return
               end
               if vim.fn.getftime(sidecar) < vim.fn.getftime(nb) then
                  vim.fn.delete(sidecar)
                  vim.notify("Removed stale jupytext sidecar " .. vim.fs.basename(sidecar), vim.log.levels.INFO)
               else
                  vim.notify(
                     "Loading existing "
                        .. vim.fs.basename(sidecar)
                        .. " (newer than the notebook); delete it to reload from .ipynb",
                     vim.log.levels.WARN
                  )
               end
            end,
         })
      end,
      opts = {
         style = "hydrogen",
         output_extension = "auto",
         force_ft = nil,
      },
   },

   {
      "3rd/image.nvim",
      lazy = true, -- pulled in by molten
      opts = {
         backend = "kitty",
         processor = "magick_cli", -- homebrew imagemagick; no luarocks needed
         max_width = 100,
         max_height = 12,
         max_height_window_percentage = math.huge,
         max_width_window_percentage = math.huge,
         window_overlap_clear_enabled = true,
         window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
         integrations = {
            -- render-markdown.nvim owns markdown buffers; keep image.nvim out
            -- of them so the two don't fight over the same lines.
            markdown = { enabled = false },
            neorg = { enabled = false },
         },
      },
   },

   {
      "benlubas/molten-nvim",
      version = "^1.0.0",
      dependencies = { "3rd/image.nvim" },
      build = ":UpdateRemotePlugins",
      ft = { "python", "markdown", "quarto" },
      init = function()
         vim.g.molten_image_provider = "image.nvim"
         vim.g.molten_output_win_max_height = 20
         vim.g.molten_wrap_output = true
         -- Output as virtual text under the cell, like a notebook; the float
         -- is still available on <leader>jo for long/image output.
         vim.g.molten_auto_open_output = false
         vim.g.molten_virt_text_output = true
         -- off_by_1 would draw the output over the line *after* the cell,
         -- which doesn't exist for the last cell of a notebook → no output.
         vim.g.molten_virt_lines_off_by_1 = false
         vim.g.molten_use_border_highlights = true
      end,
      config = function()
         local py = require("rvldodo.core.python")

         -- ── kernel selection / registration ──────────────────────────
         -- Every project gets its own kernelspec, named after the project
         -- root dir and pointing at the project's venv, so the kernel sees
         -- exactly the packages the LSP does. Registration is automatic: the
         -- first <leader>ji / <leader>jj in a project installs ipykernel into
         -- the venv (uv) and runs `ipykernel install --user`. Stale specs
         -- (venv deleted or recreated) are re-registered the same way.
         -- Projects without a venv fall back to the global `python3` kernel
         -- (registered from the `uv tool install jupyter-core` env).
         local function host()
            return vim.g.python3_host_prog or "python3"
         end

         local function run(cmd, opts)
            return vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {})):wait()
         end

         --- name → { python = argv[0], dir = resource_dir }, as molten sees them.
         local function kernelspecs()
            local r = run({
               host(),
               "-c",
               "import json, jupyter_client.kernelspec as k; "
                  .. "print(json.dumps({n: {'python': d['spec']['argv'][0], 'dir': d['resource_dir']} "
                  .. "for n, d in k.KernelSpecManager().get_all_specs().items()}))",
            })
            local ok, specs = pcall(vim.json.decode, r.stdout or "")
            return ok and type(specs) == "table" and specs or {}
         end

         --- Kernelspec names must be [a-z0-9._-].
         local function kernel_name()
            return (vim.fs.basename(py.project_root()):lower():gsub("[^%w%._%-]", "-"))
         end

         --- Install ipykernel into `python`'s venv if missing, then register
         --- it under `name`. Returns true on success.
         local function register_kernel(python, name)
            if run({ python, "-c", "import ipykernel" }).code ~= 0 then
               vim.notify("Installing ipykernel into " .. vim.fs.dirname(vim.fs.dirname(python)), vim.log.levels.INFO)
               local cmd = vim.fn.executable("uv") == 1
                     and { "uv", "pip", "install", "--python", python, "ipykernel" }
                  or { python, "-m", "pip", "install", "ipykernel" }
               local r = run(cmd)
               if r.code ~= 0 then
                  vim.notify("ipykernel install failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
                  return false
               end
            end
            local r = run({
               python, "-m", "ipykernel", "install", "--user",
               "--name", name, "--display-name", "Python (" .. name .. ")",
            })
            if r.code ~= 0 then
               vim.notify("kernelspec install failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
               return false
            end
            vim.notify("Registered Jupyter kernel '" .. name .. "' → " .. python, vim.log.levels.INFO)
            return true
         end

         --- Kernelspec name to hand to MoltenInit, registering/repairing the
         --- project's spec as needed. nil when the user cancels or it fails.
         local function resolve_kernel()
            local root = py.project_root()
            local name = kernel_name()
            local venv = py.venv_root()
            local spec = kernelspecs()[name]

            if spec and vim.fn.executable(spec.python) == 1 then
               -- Reuse unless the project now has a venv the spec doesn't point at.
               if not venv or vim.fs.dirname(spec.python) == venv .. "/bin" then
                  return name
               end
            end

            if not venv then
               local choice = vim.fn.confirm(
                  "No virtualenv found in " .. root .. ".",
                  "&Create .venv with uv\n&Use global python3 kernel\n&Cancel",
                  1
               )
               if choice == 1 then
                  -- uv honours a .python-version in root, if any.
                  local r = run({ "uv", "venv", root .. "/.venv" }, { cwd = root })
                  if r.code ~= 0 then
                     vim.notify("uv venv failed:\n" .. (r.stderr or ""), vim.log.levels.ERROR)
                     return nil
                  end
                  venv = root .. "/.venv"
               elseif choice == 2 then
                  return "python3"
               else
                  return nil
               end
            end

            return register_kernel(venv .. "/bin/python", name) and name or nil
         end

         local function init_kernel()
            local kernel = resolve_kernel()
            if kernel then
               vim.cmd("MoltenInit " .. kernel)
            end
         end

         --- Force (re)registration, e.g. after recreating the venv.
         local function reregister_kernel()
            local venv = py.venv_root()
            if not venv then
               vim.notify("No virtualenv in " .. py.project_root() .. "; create one first (uv venv)", vim.log.levels.WARN)
               return
            end
            register_kernel(venv .. "/bin/python", kernel_name())
         end

         -- molten exposes no "is a kernel attached?" query, so track it via
         -- its autocmds; run_cell uses this to init on demand instead of
         -- letting molten throw up a numbered picker.
         local grp = vim.api.nvim_create_augroup("MoltenKernelState", { clear = true })
         vim.api.nvim_create_autocmd("User", {
            pattern = "MoltenInitPost",
            group = grp,
            callback = function()
               vim.b.molten_ready = true
            end,
         })
         vim.api.nvim_create_autocmd("User", {
            pattern = "MoltenDeinitPost",
            group = grp,
            callback = function()
               vim.b.molten_ready = false
            end,
         })

         local function ensure_kernel()
            if not vim.b.molten_ready then
               init_kernel() -- MoltenInit is a sync RPC call; safe to evaluate right after
            end
            return vim.b.molten_ready
         end

         -- Notebooks assume cwd == the notebook's folder (relative data paths,
         -- `load_dotenv()` walking up to the project .env). The kernel inherits
         -- the RPC host's cwd instead, so chdir it right after init.
         vim.api.nvim_create_autocmd("User", {
            pattern = "MoltenInitPost",
            group = vim.api.nvim_create_augroup("MoltenProjectCwd", { clear = true }),
            callback = function()
               local dir = vim.fn.expand("%:p:h")
               vim.cmd(("MoltenEvaluateArgument import os; os.chdir(%q)"):format(dir))
            end,
         })

         -- ── `# %%` cell helpers ──────────────────────────────────────
         local MARKER = "^%s*#%s*%%%%"

         local function is_marker(lnum)
            return vim.fn.getline(lnum):match(MARKER) ~= nil
         end

         --- 1-based [first, last] code lines of the cell under the cursor,
         --- plus the line of the next marker (or nil at end of buffer).
         local function cell_bounds()
            local cur, last = vim.fn.line("."), vim.fn.line("$")
            local first = cur
            while first > 1 and not is_marker(first) do
               first = first - 1
            end
            local marker = is_marker(first) and first or nil
            first = marker and marker + 1 or first

            local nxt = cur + 1
            while nxt <= last and not is_marker(nxt) do
               nxt = nxt + 1
            end
            local stop = nxt - 1
            if nxt > last then
               nxt = nil
            end
            return first, stop, nxt, marker
         end

         local function run_cell()
            local first, stop, _, marker = cell_bounds()
            if marker and vim.fn.getline(marker):find("[markdown]", 1, true) then
               vim.notify("Markdown cell — nothing to run", vim.log.levels.INFO)
               return
            end
            if first > stop or not ensure_kernel() then
               return
            end
            -- molten hangs virt-text output on the line after the cell; give
            -- a cell that ends at EOF one (jupytext drops trailing blanks).
            if stop == vim.fn.line("$") then
               vim.api.nvim_buf_set_lines(0, stop, stop, false, { "" })
            end
            vim.fn.MoltenEvaluateRange(first, stop)
         end

         local function run_cell_and_next()
            local _, _, nxt = cell_bounds()
            run_cell()
            if nxt then
               vim.api.nvim_win_set_cursor(0, { math.min(nxt + 1, vim.fn.line("$")), 0 })
            end
         end

         local function goto_cell(dir)
            local cur, last = vim.fn.line("."), vim.fn.line("$")
            local l = cur + dir
            while l >= 1 and l <= last do
               if is_marker(l) then
                  vim.api.nvim_win_set_cursor(0, { math.min(l + 1, last), 0 })
                  return
               end
               l = l + dir
            end
         end

         local function new_cell_below()
            local _, stop = cell_bounds()
            vim.api.nvim_buf_set_lines(0, stop, stop, false, { "", "# %%", "" })
            vim.api.nvim_win_set_cursor(0, { stop + 3, 0 })
            vim.cmd("startinsert")
         end

         -- ── keymaps (<leader>j = jupyter) ────────────────────────────
         local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
         end

         map("n", "<leader>ji", init_kernel, "Jupyter: init kernel")
         map("n", "<leader>jk", reregister_kernel, "Jupyter: (re)register project kernel")
         map("n", "<leader>jq", "<cmd>MoltenDeinit<cr>", "Jupyter: stop kernel")
         map("n", "<leader>jR", "<cmd>MoltenRestart!<cr>", "Jupyter: restart kernel (clear outputs)")
         map("n", "<leader>jx", "<cmd>MoltenInterrupt<cr>", "Jupyter: interrupt")

         map("n", "<leader>jj", run_cell, "Jupyter: run cell")
         map("n", "<leader>jJ", run_cell_and_next, "Jupyter: run cell, go to next")
         map("n", "<leader>jl", function()
            if ensure_kernel() then
               vim.cmd("MoltenEvaluateLine")
            end
         end, "Jupyter: run line")
         map("v", "<leader>j", function()
            if ensure_kernel() then
               vim.cmd("normal! \27") -- leave visual so '< '> marks are set
               vim.cmd("MoltenEvaluateVisual")
            end
         end, "Jupyter: run selection")
         map("n", "<leader>je", "<cmd>MoltenEvaluateOperator<cr>", "Jupyter: run motion")
         map("n", "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", "Jupyter: re-run cell")
         map("n", "<leader>ja", function()
            if ensure_kernel() then
               vim.fn.MoltenEvaluateRange(1, vim.fn.line("$"))
            end
         end, "Jupyter: run all")

         map("n", "<leader>jo", "<cmd>noautocmd MoltenEnterOutput<cr>", "Jupyter: open output")
         map("n", "<leader>jh", "<cmd>MoltenHideOutput<cr>", "Jupyter: hide output")
         map("n", "<leader>jd", "<cmd>MoltenDelete<cr>", "Jupyter: delete cell output")
         map("n", "<leader>jp", "<cmd>MoltenImagePopup<cr>", "Jupyter: open image in viewer")

         map("n", "<leader>jn", new_cell_below, "Jupyter: new cell below")
         map("n", "]j", function()
            goto_cell(1)
         end, "Jupyter: next cell")
         map("n", "[j", function()
            goto_cell(-1)
         end, "Jupyter: previous cell")

         -- Saved outputs travel with the .ipynb; molten can read/write them.
         map("n", "<leader>jL", "<cmd>MoltenImportOutput<cr>", "Jupyter: load saved outputs")
         map("n", "<leader>jE", "<cmd>MoltenExportOutput!<cr>", "Jupyter: save outputs to .ipynb")
      end,
   },
}
