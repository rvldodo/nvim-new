-- Resolve which Python interpreter the current project should use.
--
-- Shared by lsp/lspconfig.lua (pyright/ruff) and plugins/debugger.lua
-- (nvim-dap-python) so the LSP and the debugger never disagree about which
-- interpreter — and therefore which installed packages — a buffer sees.
--
-- venv-selector exports $VIRTUAL_ENV when you pick an env at runtime, so that
-- takes precedence over anything discovered on disk.
--
-- vim.g.python3_host_prog is intentionally NOT consulted: it points at the
-- neovim-only venv (pynvim/jupyter_client for molten) set in core/options.lua,
-- which has none of a project's packages.

local M = {}

-- Ordered: first hit wins.
local VENV_DIRS = { ".venv", "venv", ".env", "env" }

local function is_exec(path)
   return path ~= nil and vim.fn.executable(path) == 1
end

--- Root of the current project, falling back to cwd.
local function project_root()
   local markers = { "pyproject.toml", "requirements.txt", "setup.py", "setup.cfg", "manage.py", ".git" }
   local found = vim.fs.find(markers, { upward = true, path = vim.fn.expand("%:p:h") })[1]
   return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

M.project_root = project_root

--- Absolute path to the interpreter for this project.
--- Order: $VIRTUAL_ENV (venv-selector pick) > ./.venv etc > pyenv > PATH.
function M.interpreter()
   local active = os.getenv("VIRTUAL_ENV")
   if active then
      local p = active .. "/bin/python"
      if is_exec(p) then
         return p
      end
   end

   local root = project_root()
   for _, dir in ipairs(VENV_DIRS) do
      local p = root .. "/" .. dir .. "/bin/python"
      if is_exec(p) then
         return p
      end
   end

   -- pyenv shim respects .python-version; uv writes that file too.
   local pyenv = vim.fn.expand("~/.pyenv/shims/python")
   if is_exec(pyenv) then
      return pyenv
   end

   return vim.fn.exepath("python3")
end

--- Directory holding the resolved interpreter's venv, or nil if not in one.
function M.venv_root()
   local py = M.interpreter()
   local bin = vim.fs.dirname(py) -- .../bin
   local root = vim.fs.dirname(bin) -- .../<venv>
   if is_exec(root .. "/bin/python") and vim.fn.isdirectory(root .. "/lib") == 1 then
      return root
   end
   return nil
end

return M
