-- C / C++ tooling.
-- LSP (clangd) lives in lsp/lspconfig.lua, formatting in formatting.lua,
-- DAP adapters in debugger.lua, single-file quick-run in core/cpp.lua.
return {
   -- ── CMake ───────────────────────────────────────────────────────────
   -- Generating with CMAKE_EXPORT_COMPILE_COMMANDS is what feeds clangd its
   -- compile_commands.json; without it clangd guesses include paths and every
   -- third-party header shows up as "file not found".
   {
      "Civitasv/cmake-tools.nvim",
      ft = { "c", "cpp", "cmake" },
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {
         cmake_command = "cmake",
         cmake_build_directory = "build",
         cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
         cmake_soft_link_compile_commands = true, -- symlink build/compile_commands.json to the project root
         -- :CMakeDebug hands off to the codelldb adapter registered in debugger.lua.
         cmake_dap_configuration = {
            name = "cpp",
            type = "codelldb",
            request = "launch",
            stopOnEntry = false,
            runInTerminal = true,
            console = "integratedTerminal",
         },
         cmake_executor = { name = "quickfix" },
         cmake_runner = { name = "terminal" },
      },
      keys = {
         { "<leader>cg", "<cmd>CMakeGenerate<cr>", desc = "CMake: generate" },
         { "<leader>cb", "<cmd>CMakeBuild<cr>", desc = "CMake: build" },
         -- `<leader>cR` is Snacks' rename-file (plugins/snack.lua), so run/debug
         -- take the lowercase pair here.
         { "<leader>cr", "<cmd>CMakeRun<cr>", desc = "CMake: run" },
         { "<leader>cd", "<cmd>CMakeDebug<cr>", desc = "CMake: debug" },
         { "<leader>ct", "<cmd>CMakeSelectBuildTarget<cr>", desc = "CMake: select target" },
         { "<leader>cT", "<cmd>CMakeSelectBuildType<cr>", desc = "CMake: select build type" },
         { "<leader>cx", "<cmd>CMakeClose<cr>", desc = "CMake: close runner/executor" },
      },
   },
}
