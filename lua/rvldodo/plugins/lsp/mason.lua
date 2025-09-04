return {
   {
      "williamboman/mason.nvim",
      dependencies = {
         "williamboman/mason-lspconfig.nvim",
         "WhoIsSethDaniel/mason-tool-installer.nvim",
      },
      config = function()
         -- import mason
         local mason = require("mason")

         -- enable mason and configure icons
         mason.setup({
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
      dependencies = { "williamboman/mason.nvim" },
      config = function()
         local mason_lspconfig = require("mason-lspconfig")

         mason_lspconfig.setup({
            -- list of servers for mason to install
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
               -- "pyright",
               -- "jdtls",
               -- "kotlin_language_server",
            },
         })
      end,
   },
   {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      dependencies = { "williamboman/mason.nvim" },
      config = function()
         local mason_tool_installer = require("mason-tool-installer")

         mason_tool_installer.setup({
            ensure_installed = {
               "biome",
               "prettier",
               "stylua",
               "isort",
               "black",
               "pylint",
               "eslint_d",
               "golines",
               "gomodifytags",
               "protolint",
               "google-java-format",
               "ktlint",
               "checkstyle",
               "sqlfluff",
            },
         })
      end,
   },
}
