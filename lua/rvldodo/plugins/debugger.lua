return {
   {
      "mfussenegger/nvim-dap",
      dependencies = {
         "rcarriga/nvim-dap-ui",
         "leoluz/nvim-dap-go",
         "nvim-neotest/nvim-nio",
      },

      config = function()
         local dap, dapui = require("dap"), require("dapui")

         require("dapui").setup()
         require("dap-go").setup()

         dap.listeners.before.attach.dapui_config = function()
            dapui.open()
         end
         dap.listeners.before.launch.dapui_config = function()
            dapui.open()
         end
         dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
         end
         dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
         end

         -- ── C / C++ ──────────────────────────────────────────────────
         -- Reuses the codelldb that rustaceanvim already installs rather than
         -- pulling in a second native adapter.
         local mason = vim.fn.stdpath("data") .. "/mason/packages"

         dap.adapters.codelldb = {
            type = "server",
            port = "${port}",
            executable = {
               command = mason .. "/codelldb/extension/adapter/codelldb",
               args = { "--port", "${port}" },
            },
         }

         local native_configs = {
            {
               name = "Launch executable",
               type = "codelldb",
               request = "launch",
               -- Defaults to build/ because that's where :CMakeGenerate puts
               -- things; edit the prompt for a plain `c++ -o` binary.
               program = function()
                  return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
               end,
               cwd = "${workspaceFolder}",
               stopOnEntry = false,
               args = function()
                  return vim.split(vim.fn.input("Args: "), " ", { trimempty = true })
               end,
               console = "integratedTerminal",
            },
            {
               name = "Attach to process",
               type = "codelldb",
               request = "attach",
               pid = require("dap.utils").pick_process,
               cwd = "${workspaceFolder}",
            },
         }

         dap.configurations.c = native_configs
         dap.configurations.cpp = native_configs
         dap.configurations.objc = native_configs

         -- ── C# ───────────────────────────────────────────────────────
         -- Mason unpacks netcoredbg to libexec/netcoredbg/netcoredbg inside the
         -- package dir, so go through the bin shim instead of guessing the path.
         -- On Apple Silicon this is the x64 build: it needs Rosetta.
         dap.adapters.coreclr = {
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
            args = { "--interpreter=vscode" },
         }

         dap.configurations.cs = {
            {
               name = "Launch (.NET)",
               type = "coreclr",
               request = "launch",
               -- netcoredbg wants the built .dll, not the .csproj. Run
               -- `dotnet build` first; the path is bin/Debug/<tfm>/<name>.dll.
               program = function()
                  return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
               end,
               cwd = "${workspaceFolder}",
               stopAtEntry = false,
            },
            {
               name = "Attach to process (.NET)",
               type = "coreclr",
               request = "attach",
               processId = require("dap.utils").pick_process,
               cwd = "${workspaceFolder}",
            },
         }

         -- ── Node / Express / NestJS / Jest ───────────────────────────
         -- vscode-js-debug (mason: js-debug-adapter). neotest-jest's dap
         -- strategy also targets the `pwa-node` type, so <leader>td works
         -- for jest once this adapter exists.
         local ts = require("rvldodo.core.typescript")

         dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
               command = "node",
               args = { mason .. "/js-debug-adapter/js-debug/src/dapDebugServer.js", "${port}" },
            },
         }

         -- Ask which package.json script to launch. Returned as a coroutine:
         -- nvim-dap waits on it, so vim.ui.select's callback can resume it.
         local function pick_script()
            return coroutine.create(function(co)
               local names = vim.tbl_keys(ts.package_json().scripts or {})
               table.sort(names)
               vim.ui.select(names, { prompt = "Debug script" }, function(choice)
                  -- Scheduled: some vim.ui.select backends call back before
                  -- nvim-dap has yielded, and resuming then errors.
                  vim.schedule(function()
                     coroutine.resume(co, choice and { "run", choice } or dap.ABORT)
                  end)
               end)
            end)
         end

         local js_configs = {
            {
               -- Day-to-day flow: start the server with the inspector in a
               -- terminal — `npm run start:debug` (Nest), `nodemon --inspect
               -- app.js` or `node --inspect app.js` (Express) — then attach.
               -- `restart` re-attaches every time the watcher restarts it.
               name = "Node / NestJS: attach to :9229",
               type = "pwa-node",
               request = "attach",
               port = 9229,
               restart = true,
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
               -- Express `dev` / `start` (nodemon, node --watch, tsx watch, …)
               -- with nvim owning the process. js-debug injects the inspector
               -- through NODE_OPTIONS, so the script needs no --inspect, and
               -- autoAttachChildProcesses follows nodemon into its node child.
               name = "Node: launch package.json script…",
               type = "pwa-node",
               request = "launch",
               runtimeExecutable = ts.package_manager,
               runtimeArgs = pick_script,
               autoAttachChildProcesses = true,
               restart = true,
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
               -- Same thing but nvim owns the process. The Nest CLI spawns
               -- node as a child, hence autoAttachChildProcesses.
               name = "NestJS: launch start:debug",
               type = "pwa-node",
               request = "launch",
               runtimeExecutable = ts.package_manager,
               runtimeArgs = { "run", "start:debug" },
               autoAttachChildProcesses = true,
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
               -- Nest ≤ 11 projects. Nest e2e specs need their own config.
               name = "Jest: debug current file",
               type = "pwa-node",
               request = "launch",
               runtimeExecutable = "node",
               runtimeArgs = function()
                  local args = {
                     "${workspaceFolder}/node_modules/jest/bin/jest.js",
                     "--runInBand",
                     "--no-coverage",
                  }
                  if vim.fn.expand("%:t"):match("%.e2e%-spec%.[tj]sx?$") then
                     vim.list_extend(args, { "--config", "test/jest-e2e.json" })
                  end
                  table.insert(args, "${file}")
                  return args
               end,
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
               -- Nest 12+ projects. Vitest runs files in worker processes,
               -- hence autoAttachChildProcesses; --no-file-parallelism keeps
               -- it to one so breakpoints land where you expect.
               name = "Vitest: debug current file",
               type = "pwa-node",
               request = "launch",
               runtimeExecutable = "node",
               runtimeArgs = function()
                  local args = {
                     "${workspaceFolder}/node_modules/vitest/vitest.mjs",
                     "run",
                     "--no-file-parallelism",
                  }
                  if vim.fn.expand("%:t"):match("%.e2e%-spec%.[tj]sx?$") then
                     vim.list_extend(args, { "--config", "vitest.config.e2e.ts" })
                  end
                  table.insert(args, "${file}")
                  return args
               end,
               autoAttachChildProcesses = true,
               smartStep = true,
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
            {
               -- Older Express projects: mocha + chai + supertest.
               name = "Mocha: debug current file",
               type = "pwa-node",
               request = "launch",
               runtimeExecutable = "node",
               runtimeArgs = { "${workspaceFolder}/node_modules/mocha/bin/mocha.js", "--timeout", "999999", "${file}" },
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
         }

         -- Plain TS (Express + tsx) can run the file directly through the
         -- project's tsx. Not for Nest: esbuild drops emitDecoratorMetadata,
         -- which Nest's DI needs — use the start:debug entries there.
         dap.configurations.typescript = vim.list_extend({
            {
               name = "Node: launch current file (tsx)",
               type = "pwa-node",
               request = "launch",
               runtimeExecutable = function()
                  return ts.local_bin("tsx") or "tsx"
               end,
               program = "${file}",
               cwd = "${workspaceFolder}",
               sourceMaps = true,
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
         }, vim.list_slice(js_configs))
         -- Plain JS can also just run the file; a Nest .ts file can't (node
         -- won't strip decorators), so that entry stays JS-only.
         dap.configurations.javascript = vim.list_extend({
            {
               name = "Node: launch current file",
               type = "pwa-node",
               request = "launch",
               program = "${file}",
               cwd = "${workspaceFolder}",
               console = "integratedTerminal",
               skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            },
         }, js_configs)

         vim.keymap.set("n", "<Leader>dt", ":DapUiToggle<CR>", {})
         vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
         vim.keymap.set("n", "<Leader>dc", dap.continue, {})
         vim.keymap.set("n", "<Leader>dr", ":lua require('dapui').open({reset = true})<CR>", {})

         vim.fn.sign_define(
            "DapBreakpoint",
            { text = "?", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" }
         )
      end,
   },
   {
      "mfussenegger/nvim-dap-python",
      ft = "python",
      dependencies = {
         "mfussenegger/nvim-dap",
      },
      config = function()
         local dap = require("dap")
         local py = require("rvldodo.core.python")

         -- Two different interpreters, and the distinction matters:
         --   adapter  — must have debugpy importable. Mason's own venv does;
         --              your project venv almost certainly does not.
         --   debuggee — must be the project venv, or the code under test
         --              can't import its own dependencies.
         -- Passing the project venv as the adapter (the obvious-looking move)
         -- fails with "No module named debugpy".
         local adapter = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

         require("dap-python").setup(adapter)

         -- dapui listeners are registered once in the nvim-dap block above;
         -- re-registering them here would open/close the UI twice per session.

         -- Point every python config at the project interpreter, and give the
         -- web frameworks a launch config each so <leader>dc just works.
         dap.configurations.python = {
            {
               type = "python",
               request = "launch",
               name = "Launch file",
               program = "${file}",
               pythonPath = py.interpreter,
               console = "integratedTerminal",
               justMyCode = false,
            },
            {
               type = "python",
               request = "launch",
               name = "Django (runserver)",
               program = function()
                  return py.project_root() .. "/manage.py"
               end,
               args = { "runserver", "--noreload" }, -- --noreload: the autoreloader forks and drops breakpoints
               pythonPath = py.interpreter,
               console = "integratedTerminal",
               justMyCode = false,
               django = true,
            },
            {
               type = "python",
               request = "launch",
               name = "Flask",
               module = "flask",
               args = { "--app", "app", "run", "--no-debugger", "--no-reload" },
               env = { FLASK_ENV = "development" },
               pythonPath = py.interpreter,
               console = "integratedTerminal",
               justMyCode = false,
               jinja = true,
            },
            {
               type = "python",
               request = "launch",
               name = "FastAPI (uvicorn)",
               module = "uvicorn",
               args = function()
                  local target = vim.fn.input("uvicorn target (default main:app): ")
                  if target == "" then
                     target = "main:app"
                  end
                  return { target, "--reload-dir", ".", "--port", "8000" }
               end,
               pythonPath = py.interpreter,
               console = "integratedTerminal",
               justMyCode = false,
               jinja = true,
            },
            {
               type = "python",
               request = "launch",
               name = "Pytest (current file)",
               module = "pytest",
               args = { "${file}", "-vv", "-s" },
               pythonPath = py.interpreter,
               console = "integratedTerminal",
               justMyCode = false,
            },
         }

         -- Debug the test under the cursor / the enclosing class.
         vim.keymap.set("n", "<leader>dn", function()
            require("dap-python").test_method()
         end, { desc = "Debug nearest python test" })
         vim.keymap.set("n", "<leader>df", function()
            require("dap-python").test_class()
         end, { desc = "Debug python test class" })
         vim.keymap.set("v", "<leader>ds", function()
            require("dap-python").debug_selection()
         end, { desc = "Debug python selection" })
      end,
   },
}
