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
               "html",
               "cssls",
               "tailwindcss",
               "svelte",
               "lua_ls",
               "graphql",
               "gopls",
               "emmet_ls",
               "prismals",
               "pyright",
               "rust_analyzer",
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
               "codelldb", -- needed by rustaceanvim DAP
            },
            auto_update = false,
            run_on_start = true, -- 🔥 IMPORTANT
         })
      end,
   },
}
