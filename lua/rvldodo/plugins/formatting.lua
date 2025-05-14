return {
   "stevearc/conform.nvim",
   event = { "BufReadPre", "BufNewFile" },
   config = function()
      local conform = require("conform")

      -- Define SQL filetypes
      local sql_ft = { "sql", "mysql", "plsql" } -- Add any other SQL dialects you need

      conform.setup({
         formatters_by_ft = {
            javascript = { "biome" },
            typescript = { "biome" },
            javascriptreact = { "biome" },
            typescriptreact = { "biome" },
            svelte = { "prettier" },
            css = { "prettier" },
            html = { "prettier" },
            json = { "biome" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            graphql = { "prettier" },
            liquid = { "prettier" },
            lua = { "stylua" },
            python = { "isort", "black" },
            golang = { "golines" },
            proto = { "protolint" },
            java = { "google-java-format" },
            kt = { "ktlint" },
            kotlin = { "ktlint" },
            -- SQL formatters will be added in the opts function below
         },
         format_on_save = {
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
         },
         -- Add the SQLFluff configuration
         formatters = {
            sqlfluff = {
               args = { "format", "--dialect=ansi", "-" },
            },
         },
      })

      -- Add SQL formatters to the appropriate filetypes
      for _, ft in ipairs(sql_ft) do
         conform.formatters_by_ft[ft] = conform.formatters_by_ft[ft] or {}
         table.insert(conform.formatters_by_ft[ft], "sqlfluff")
      end

      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
         conform.format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
         })
      end, { desc = "Format file or range (in visual mode)" })
   end,
}
