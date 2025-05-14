return {
   "williamboman/mason.nvim",
   dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
   },
   config = function()
      -- import mason
      local mason = require("mason")

      -- import mason-lspconfig
      local mason_lspconfig = require("mason-lspconfig")

      local mason_tool_installer = require("mason-tool-installer")

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

      mason_lspconfig.setup({
         -- list of servers for mason to install
         ensure_installed = {
            -- "rust-analyzer",
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
            -- "proto",

            -- Add Java & Kotlin LSP servers
            "jdtls", -- Java (via Eclipse JDT)
            "kotlin_language_server", -- Kotlin
            -- Remove sqlfluff from here (it's not an LSP server)
         },
      })

      mason_tool_installer.setup({
         ensure_installed = {
            "biome",
            "prettier", -- prettier formatter
            "stylua", -- lua formatter
            "isort", -- python formatter
            "black", -- python formatter
            "pylint", -- python linter
            "eslint_d", -- js linter
            "golines",
            "gomodifytags",
            "protolint",

            -- Add Java & Kotlin formatters/linters
            "google-java-format", -- Java formatter
            "ktlint", -- Kotlin formatter/linter
            "checkstyle", -- Optional: Java linter
            "sqlfluff", -- Add sqlfluff here as it's a linter/formatter
         },
      })
   end,
}
