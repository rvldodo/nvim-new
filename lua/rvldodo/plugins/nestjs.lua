-- NestJS / Express / TypeScript backend tooling: test runner (jest, vitest
-- or mocha),
-- project-wide typecheck, package.json version hints. LSP lives in
-- lsp/lspconfig.lua (ts_ls + eslint/oxlint), formatting + lint-fix in
-- formatting.lua, DAP in debugger.lua, snippets in <config>/snippets/nestjs.lua,
-- `nest g` in core/nestjs.lua, project detection in core/typescript.lua.
return {
   -- ── test runner (jest / vitest / mocha) ─────────────────────────────
   -- Extends the neotest spec from plugins/python.lua; the <leader>t*
   -- keymaps are defined there and work for every adapter.
   --
   -- Both adapters are registered and each only claims files in a project
   -- that actually uses its runner (core/typescript.lua decides), otherwise
   -- neotest-jest — first in the list — would grab vitest specs too.
   {
      "nvim-neotest/neotest",
      ft = { "typescript", "javascript" },
      dependencies = {
         "nvim-neotest/neotest-jest",
         "marilari88/neotest-vitest",
         "adrigzr/neotest-mocha", -- Express projects on mocha + chai + supertest
      },
      opts = function(_, opts)
         local ts = require("rvldodo.core.typescript")

         local E2E = "%.e2e%-spec%.[tj]sx?$"

         -- Nest keeps e2e config apart from unit config: test/jest-e2e.json
         -- (jest) or vitest.config.e2e.ts (vitest). Point the runner at it
         -- for *.e2e-spec.ts files only; nil means "use the default lookup".
         local function e2e_config(file, name)
            if not file:match(E2E) then
               return nil
            end
            local cfg = ts.project_root(file) .. "/" .. name
            return vim.fn.filereadable(cfg) == 1 and cfg or nil
         end

         -- Replace each adapter's is_test_file rather than wrap it: the
         -- stock ones match *.spec.ts / *.test.ts (missing Nest's
         -- *.e2e-spec.ts) and re-read package.json through nio on every
         -- call, which the runner check here already covers synchronously.
         local function gate(adapter, runner)
            adapter.is_test_file = function(file)
               if type(file) ~= "string" or ts.test_runner(file) ~= runner then
                  return false
               end
               return file:match("%.spec%.[tj]sx?$") ~= nil
                  or file:match("%.test%.[tj]sx?$") ~= nil
                  or file:match(E2E) ~= nil
                  or file:match("__tests__") ~= nil
            end
            return adapter
         end

         local jest = require("neotest-jest")({
            -- The project's own jest, so its config/transform (ts-jest, swc)
            -- are what runs. `npx jest` would work but downloads jest when
            -- it's missing and blocks on the prompt.
            jestCommand = function(file)
               return ts.local_bin("jest", file) or "npx jest"
            end,
            jestConfigFile = function(file)
               return e2e_config(file, "test/jest-e2e.json")
            end,
            env = { CI = "true" }, -- never watch mode, no interactive prompts
            cwd = function(file)
               return ts.project_root(file)
            end,
         })

         local vitest = require("neotest-vitest")({
            vitestCommand = function(file)
               return ts.local_bin("vitest", file) or "npx vitest"
            end,
            vitestConfigFile = function(file)
               return e2e_config(file, "vitest.config.e2e.ts")
            end,
            env = { CI = "true" },
            cwd = function(file)
               return ts.project_root(file)
            end,
         })

         local mocha = require("neotest-mocha")({
            command = function(file)
               return ts.local_bin("mocha", file) or "npx mocha"
            end,
            env = { CI = "true" },
            cwd = function(file)
               return ts.project_root(file)
            end,
         })

         opts.adapters = opts.adapters or {}
         table.insert(opts.adapters, gate(jest, "jest"))
         table.insert(opts.adapters, gate(vitest, "vitest"))
         table.insert(opts.adapters, gate(mocha, "mocha"))
      end,
   },

   -- ── project-wide typecheck ──────────────────────────────────────────
   -- ts_ls only reports on open buffers. `:TSC` runs tsc --noEmit over the
   -- whole project (async) and drops errors into the quickfix list, the
   -- same signal `nest build` fails on.
   {
      "dmmulroy/tsc.nvim",
      cmd = { "TSC", "TSCOpen", "TSCClose", "TSCStop" },
      keys = {
         { "<leader>tc", "<cmd>TSC<CR>", desc = "TS: typecheck project (tsc --noEmit)" },
      },
      opts = {
         auto_open_qflist = true,
         auto_close_qflist = false,
         use_trouble_qflist = true, -- trouble.nvim is already in this config
         flags = {
            noEmit = true,
            -- Nest ships tsconfig.json (editor) + tsconfig.build.json (build);
            -- the build one excludes specs, so check with the editor one.
            project = function()
               return vim.fs.find("tsconfig.json", { upward = true, path = vim.fn.expand("%:p:h") })[1]
            end,
         },
         pretty_errors = true,
      },
   },

   -- ── package.json version hints ──────────────────────────────────────
   -- Latest-version virtual text next to each dependency, like crates.nvim
   -- does for Cargo.toml. Runs the detected package manager for changes.
   {
      "vuki656/package-info.nvim",
      dependencies = { "MunifTanjim/nui.nvim" },
      event = { "BufRead package.json" },
      opts = {
         hide_up_to_date = true,
         package_manager = "npm", -- overridden per project below
      },
      config = function(_, opts)
         local ts = require("rvldodo.core.typescript")
         opts.package_manager = ts.package_manager()
         if opts.package_manager == "bun" then
            opts.package_manager = "npm" -- package-info only speaks npm/yarn/pnpm
         end
         require("package-info").setup(opts)

         local pi = require("package-info")
         local map = function(lhs, fn, desc)
            vim.keymap.set("n", lhs, fn, { silent = true, desc = desc })
         end
         map("<leader>ps", pi.show, "package.json: show latest versions")
         map("<leader>ph", pi.hide, "package.json: hide versions")
         map("<leader>pu", pi.update, "package.json: update dependency")
         map("<leader>pd", pi.delete, "package.json: delete dependency")
         map("<leader>pi", pi.install, "package.json: install dependency")
         map("<leader>pv", pi.change_version, "package.json: change version")
      end,
   },
}
