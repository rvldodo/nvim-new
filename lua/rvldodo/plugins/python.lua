-- Python-specific tooling: venv picker, test runner, and template filetypes.
-- LSP lives in lsp/lspconfig.lua, formatting in formatting.lua, DAP in debugger.lua.
return {
   -- ── venv picker ─────────────────────────────────────────────────────
   -- Pyright resolves the interpreter once, at attach. When a project has
   -- more than one env (or you create .venv after opening nvim), you need a
   -- way to switch and restart the server without leaving the editor.
   {
      "linux-cultist/venv-selector.nvim",
      branch = "regexp", -- the `main` branch is unmaintained; regexp is the current line
      ft = "python",
      dependencies = {
         "neovim/nvim-lspconfig",
         "nvim-telescope/telescope.nvim",
         "mfussenegger/nvim-dap-python",
      },
      opts = {
         settings = {
            search = {
               -- uv/venv envs living inside the project itself.
               cwd = {
                  command = "fd '/bin/python$' . --full-path --color never -E /proc -HI -a -L",
               },
               -- Central caches: uv's shared env dir and pyenv's versions.
               uv = {
                  command = "fd '/bin/python$' ~/.local/share/uv/python --full-path --color never -E /proc -HI -a -L",
               },
               pyenv = {
                  command = "fd '/bin/python$' ~/.pyenv/versions --full-path --color never -E /proc -HI -a -L",
               },
            },
            options = {
               -- Show the parent dir, so two projects both named `.venv`
               -- are distinguishable in the picker.
               notify_user_on_venv_activation = true,
            },
         },
      },
      keys = {
         { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select python venv" },
         { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Use last venv for this project" },
      },
   },

   -- ── test runner ─────────────────────────────────────────────────────
   -- neotest itself is shared: plugins/nestjs.lua adds the jest adapter to
   -- this same spec (lazy merges `ft`, `dependencies` and `opts`), so the
   -- <leader>t* keymaps below drive both pytest and jest.
   {
      "nvim-neotest/neotest",
      ft = "python",
      dependencies = {
         "nvim-neotest/nvim-nio",
         "nvim-lua/plenary.nvim",
         "antoinemadec/FixCursorHold.nvim",
         "nvim-treesitter/nvim-treesitter",
         "nvim-neotest/neotest-python",
      },
      opts = function(_, opts)
         local py = require("rvldodo.core.python")

         opts.adapters = opts.adapters or {}
         table.insert(
            opts.adapters,
            require("neotest-python")({
               -- Same interpreter as the LSP and the debugger, so a test
               -- run can't succeed against a different set of packages
               -- than the editor is type-checking.
               python = py.interpreter,
               runner = "pytest",
               -- Route "debug nearest test" through nvim-dap-python.
               dap = { justMyCode = false },
            })
         )
         opts.output = { open_on_run = false }
         opts.quickfix = { enabled = false } -- the summary panel already shows failures
      end,
      keys = {
         {
            "<leader>tr",
            function()
               require("neotest").run.run()
            end,
            desc = "Test: run nearest",
         },
         {
            "<leader>tf",
            function()
               require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = "Test: run file",
         },
         {
            "<leader>ta",
            function()
               require("neotest").run.run(vim.fn.getcwd())
            end,
            desc = "Test: run all",
         },
         {
            "<leader>td",
            function()
               require("neotest").run.run({ strategy = "dap" })
            end,
            desc = "Test: debug nearest",
         },
         {
            "<leader>ts",
            function()
               require("neotest").summary.toggle()
            end,
            desc = "Test: toggle summary",
         },
         {
            "<leader>to",
            function()
               require("neotest").output.open({ enter = true })
            end,
            desc = "Test: show output",
         },
         {
            "<leader>tS",
            function()
               require("neotest").run.stop()
            end,
            desc = "Test: stop",
         },
      },
   },

   -- ── REST client ─────────────────────────────────────────────────────
   -- Hit your own FastAPI/Django/Flask endpoints from a .http buffer.
   {
      "mistweaverco/kulala.nvim",
      keys = {
         { "<leader>rr", desc = "REST: send request" },
         { "<leader>ra", desc = "REST: send all requests" },
         { "<leader>rp", desc = "REST: jump to previous" },
         { "<leader>rn", desc = "REST: jump to next" },
      },
      ft = { "http", "rest" },
      opts = {
         global_keymaps = false,
         default_view = "body",
         default_env = "dev",
      },
      config = function(_, opts)
         require("kulala").setup(opts)

         vim.keymap.set("n", "<leader>rr", function()
            require("kulala").run()
         end, { desc = "REST: send request" })
         vim.keymap.set("n", "<leader>ra", function()
            require("kulala").run_all()
         end, { desc = "REST: send all requests" })
         vim.keymap.set("n", "<leader>rn", function()
            require("kulala").jump_next()
         end, { desc = "REST: jump to next" })
         vim.keymap.set("n", "<leader>rp", function()
            require("kulala").jump_prev()
         end, { desc = "REST: jump to previous" })
      end,
   },
}
