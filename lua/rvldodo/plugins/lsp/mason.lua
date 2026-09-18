return {
   {
      "williamboman/mason.nvim",
      version = "^1.0", -- pin to v1.x; v2 broke get_install_path + tool-installer
      build = ":MasonUpdate",
      config = function()
         require("mason").setup({
            ui = {
               icons = {
                  package_installed = "✓",
                  package_pending = "➜",
                  package_uninstalled = "✗",
               },
            },
         })
      end,
   },

   {
      "williamboman/mason-lspconfig.nvim",
      version = "^1.0", -- pin to v1.x; v2 removed setup_handlers
      dependencies = {
         "williamboman/mason.nvim",
         "neovim/nvim-lspconfig", -- 🔥 REQUIRED
      },
      config = function()
         local mason_lspconfig = require("mason-lspconfig")

         mason_lspconfig.setup({
            ensure_installed = {
               "ts_ls",
               "eslint", -- vscode-eslint-language-server: lint + fix-on-save for JS/TS (NestJS ships eslint)
               "html",
               "cssls",
               "tailwindcss",
               "svelte",
               "lua_ls",
               "graphql",
               "gopls",
               "emmet_ls",
               "prismals",
               "pyright", -- types, imports, hover, go-to-def
               "ruff", -- lint + quick-fix code actions (formatting stays in conform)
               "rust_analyzer",
               "kotlin_language_server",
               "clangd", -- C / C++ / Objective-C
               -- CMakeLists.txt completion + diagnostics. `neocmake` rather than
               -- `cmake`: cmake-language-server is pinned to the pre-2.x pygls
               -- API and crashes on import with the pygls mason installs today.
               "neocmake",
               "omnisharp", -- C# (needs the .NET SDK on PATH to resolve projects)
            },
         })
         -- NOTE: per-server setup handlers live in lsp/lspconfig.lua
      end,
   },

   {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      dependencies = { "williamboman/mason.nvim" },
      config = function()
         require("mason-tool-installer").setup({
            ensure_installed = {
               "biome",
               "prettier",
               "stylua",
               "ruff", -- replaces isort/black/pylint
               "eslint_d",
               "golines",
               "gomodifytags",
               "protolint",
               "google-java-format",
               "ktlint",
               "checkstyle",
               "sqlfluff",
               "clang-format", -- C / C++ formatting (conform)
               -- NOTE: csharpier is deliberately not here. It installs through
               -- `dotnet tool`, so without the .NET SDK mason retries and fails
               -- on every startup. After installing the SDK, run
               -- `:MasonInstall csharpier` once — conform picks it up then, and
               -- falls back to omnisharp formatting until it does.
               "codelldb", -- needed by rustaceanvim DAP + the C/C++ DAP (plugins/debugger.lua)
               "netcoredbg", -- needed by the C# DAP config (plugins/debugger.lua)
               "debugpy", -- needed by nvim-dap-python (plugins/debugger.lua)
               "js-debug-adapter", -- vscode-js-debug: Node/NestJS/Jest/Vitest DAP (plugins/debugger.lua)
               "oxlint", -- fallback linter LSP + `--fix` for Nest 12+ projects; the project-local one is preferred
            },
            auto_update = false,
            run_on_start = true, -- 🔥 IMPORTANT
         })
      end,
   },
}
