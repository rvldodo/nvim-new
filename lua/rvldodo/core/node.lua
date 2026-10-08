-- `:NpmRun [script]` — run a package.json script (dev, start, test, …) in a
-- split terminal with the project's own package manager.
--
-- Meant for Express / plain Node servers: `<leader>nr` → pick `dev` and
-- nodemon (or `node --watch`) runs next to the code. Called with no args it
-- lists the scripts from the nearest package.json via vim.ui.select.
--
-- Runs in a terminal rather than a job so server logs and Ctrl-C work as in
-- a shell. The split is reused per project: running a script again replaces
-- the previous process instead of leaving a server holding the port.

local ts = require("rvldodo.core.typescript")

-- project root -> terminal buffer of its last run
local terms = {}

local function run(script)
   local root = ts.project_root()
   local scripts = ts.package_json().scripts or {}
   if not scripts[script] then
      vim.notify(("No script %q in %s/package.json"):format(script, root), vim.log.levels.WARN)
      return
   end

   local old = terms[root]
   if old and vim.api.nvim_buf_is_valid(old) then
      -- Kills the job (and the server it started) along with the buffer.
      vim.api.nvim_buf_delete(old, { force = true })
   end

   vim.cmd("botright 12split")
   vim.cmd("enew")
   vim.fn.jobstart({ ts.package_manager(), "run", script }, { term = true, cwd = root })
   terms[root] = vim.api.nvim_get_current_buf()
   -- Follow output; <C-\><C-n> to scroll back.
   vim.cmd("normal! G")
   vim.cmd("wincmd p")
end

vim.api.nvim_create_user_command("NpmRun", function(cmd)
   if cmd.args ~= "" then
      run(cmd.args)
      return
   end

   local names = vim.tbl_keys(ts.package_json().scripts or {})
   if #names == 0 then
      vim.notify("No scripts in package.json", vim.log.levels.WARN)
      return
   end
   table.sort(names)
   local scripts = ts.package_json().scripts
   vim.ui.select(names, {
      prompt = ts.package_manager() .. " run",
      format_item = function(name)
         return ("%-14s %s"):format(name, scripts[name])
      end,
   }, function(choice)
      if choice then
         run(choice)
      end
   end)
end, {
   nargs = "?",
   desc = "Run a package.json script in a terminal split",
   complete = function()
      return vim.tbl_keys(ts.package_json().scripts or {})
   end,
})

vim.api.nvim_create_autocmd("FileType", {
   group = vim.api.nvim_create_augroup("NodeKeymaps", { clear = true }),
   pattern = { "typescript", "javascript", "json" },
   callback = function(ev)
      vim.keymap.set("n", "<leader>nr", "<cmd>NpmRun<CR>", { buffer = ev.buf, desc = "Node: run package.json script" })
   end,
})
