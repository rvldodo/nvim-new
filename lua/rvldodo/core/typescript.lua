-- Resolve project facts for a JS/TS buffer: root, package manager, formatter,
-- linter, test runner.
--
-- Shared by plugins/formatting.lua (biome vs prettier, eslint vs oxlint),
-- plugins/debugger.lua (which runner launches `start:debug`), plugins/nestjs.lua
-- (jest vs vitest adapter), core/nestjs.lua (`nest g`) and snippets/nestjs.lua,
-- so they never disagree about what "the project" is — which matters in a
-- pnpm/yarn workspace where the lockfile lives two directories above the
-- package you're editing.
--
-- Why both eslint/jest and oxlint/vitest: `nest new` switched from
-- eslint + jest (Nest ≤ 11) to oxlint + vitest (Nest 12, 2026). Existing
-- projects keep the old set; new ones get the new set. Everything here is
-- detected from the project, nothing is assumed.
--
-- Every function takes `from`: a buffer number (default: current buffer) or
-- an absolute path (neotest hands us paths, not buffers).

local M = {}

local function start_dir(from)
   if type(from) == "string" then
      return vim.fn.isdirectory(from) == 1 and from or vim.fs.dirname(from)
   end
   local name = vim.api.nvim_buf_get_name(from or 0)
   if name == "" then
      return vim.fn.getcwd()
   end
   return vim.fs.dirname(name)
end

--- Nearest file among `names`, searching upward from `from`. Returns the
--- directory containing it and the full path, or nil.
local function find_up(names, from)
   local hit = vim.fs.find(names, { upward = true, path = start_dir(from), stop = vim.env.HOME })[1]
   return hit and vim.fs.dirname(hit) or nil, hit
end

--- The package this buffer belongs to (nearest package.json), else cwd.
function M.project_root(from)
   return find_up({ "package.json" }, from) or vim.fn.getcwd()
end

local LOCKFILES = { "pnpm-lock.yaml", "yarn.lock", "bun.lock", "bun.lockb", "package-lock.json" }

--- Workspace root: where the lockfile is. Same as project_root outside a monorepo.
function M.workspace_root(from)
   return find_up(LOCKFILES, from) or M.project_root(from)
end

--- "pnpm" | "yarn" | "bun" | "npm", decided by the lockfile.
function M.package_manager(from)
   local _, lock = find_up(LOCKFILES, from)
   local name = lock and vim.fs.basename(lock) or ""
   if name == "pnpm-lock.yaml" then
      return "pnpm"
   elseif name == "yarn.lock" then
      return "yarn"
   elseif name:match("^bun%.lockb?$") then
      return "bun"
   end
   return "npm"
end

--- Path to `node_modules/.bin/<name>`, searched upward from `from`, or nil.
--- Prefer this over `npx <name>`: npx will happily download a package that
--- isn't installed and hang on the "Ok to proceed?" prompt inside a job.
function M.local_bin(name, from)
   -- Walk up rather than stop at the first node_modules: with pnpm workspaces
   -- the package's own node_modules often lacks the bin, the root's has it.
   for dir in vim.fs.parents(start_dir(from) .. "/.") do
      local bin = dir .. "/node_modules/.bin/" .. name
      if vim.fn.executable(bin) == 1 then
         return bin
      end
      if dir == vim.env.HOME then
         break
      end
   end
   return nil
end

--- Decoded package.json for the buffer's package, or {} if unreadable.
function M.package_json(from)
   local root = M.project_root(from)
   local ok, lines = pcall(vim.fn.readfile, root .. "/package.json")
   if not ok then
      return {}
   end
   local ok_json, data = pcall(vim.json.decode, table.concat(lines, "\n"))
   return ok_json and type(data) == "table" and data or {}
end

local function has_dep(pkg, name)
   return (pkg.dependencies or {})[name] ~= nil or (pkg.devDependencies or {})[name] ~= nil
end

--- True when `from` is inside a NestJS project.
function M.is_nest(from)
   local root = M.project_root(from)
   if vim.fn.filereadable(root .. "/nest-cli.json") == 1 then
      return true
   end
   return has_dep(M.package_json(from), "@nestjs/core")
end

local PRETTIER_CONFIGS = {
   ".prettierrc",
   ".prettierrc.json",
   ".prettierrc.yaml",
   ".prettierrc.yml",
   ".prettierrc.toml",
   ".prettierrc.js",
   ".prettierrc.cjs",
   ".prettierrc.mjs",
   "prettier.config.js",
   "prettier.config.cjs",
   "prettier.config.mjs",
   "prettier.config.ts",
}

--- "biome" | "prettier" for this buffer.
---
--- Nest scaffolds prettier, so formatting a Nest file with biome fights the
--- project's own `npm run format` (and eslint-plugin-prettier, where used).
--- Follow whatever config the project ships; biome stays the default for
--- projects that ship nothing (the previous behaviour of this config).
function M.formatter(from)
   local names = { "biome.json", "biome.jsonc" }
   vim.list_extend(names, PRETTIER_CONFIGS)
   local _, hit = find_up(names, from)
   if hit then
      return vim.fs.basename(hit):match("^biome%.") and "biome" or "prettier"
   end

   -- No config file: prettier may still be configured inline in package.json.
   local pkg = M.package_json(from)
   if pkg.prettier ~= nil or has_dep(pkg, "prettier") then
      return "prettier"
   end
   return "biome"
end

--- "oxlint" | "eslint" | nil. nil means no linter is configured (biome
--- projects lint through the biome LSP, which needs nothing from us).
function M.linter(from)
   if find_up({ ".oxlintrc.json" }, from) then
      return "oxlint"
   end
   if
      find_up({
         "eslint.config.js",
         "eslint.config.mjs",
         "eslint.config.cjs",
         "eslint.config.ts",
         ".eslintrc",
         ".eslintrc.js",
         ".eslintrc.cjs",
         ".eslintrc.json",
         ".eslintrc.yml",
         ".eslintrc.yaml",
      }, from)
   then
      return "eslint"
   end
   return nil
end

--- "vitest" | "jest" | nil.
function M.test_runner(from)
   if
      find_up({
         "vitest.config.ts",
         "vitest.config.mts",
         "vitest.config.js",
         "vitest.config.mjs",
         "vitest.workspace.ts",
      }, from)
   then
      return "vitest"
   end
   if
      find_up({ "jest.config.ts", "jest.config.js", "jest.config.mjs", "jest.config.cjs", "jest.config.json" }, from)
   then
      return "jest"
   end
   local pkg = M.package_json(from)
   if has_dep(pkg, "vitest") then
      return "vitest"
   elseif pkg.jest ~= nil or has_dep(pkg, "jest") then
      return "jest"
   end
   return nil
end

return M
