return {
   {
      "williamboman/mason.nvim",
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
      dependencies = {
         "williamboman/mason.nvim",
         "neovim/nvim-lspconfig", -- 🔥 REQUIRED
      },
      config = function()
         local mason_lspconfig = require("mason-lspconfig")
         local lspconfig = require("lspconfig")

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
               "rust_analyzer", -- ⚠️ FIX NAME
            },
         })

         -- 🔥 auto setup all servers
         mason_lspconfig.setup_handlers({
            function(server_name)
               lspconfig[server_name].setup({})
            end,
         })
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
               "isort",
               "black",
               "pylint",
               "ruff",
               "eslint_d",
               "golines",
               "gomodifytags",
               "protolint",
               "google-java-format",
               "ktlint",
               "checkstyle",
               "sqlfluff",
            },
            auto_update = false,
            run_on_start = true, -- 🔥 IMPORTANT
         })
      end,
   },
}
