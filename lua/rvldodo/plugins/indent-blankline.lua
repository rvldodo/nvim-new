return {
   "lukas-reineke/indent-blankline.nvim",
   event = { "BufReadPre", "BufNewFile" },
   main = "ibl",
   opts = {
      indent = { char = "┊" },
   },

   config = function()
      local highlight = {
         "RainbowDelimiterRed",
         "RainbowDelimiterYellow",
         "RainbowDelimiterBlue",
         "RainbowDelimiterOrange",
         "RainbowDelimiterGreen",
         "RainbowDelimiterViolet",
         "RainbowDelimiterCyan",
      }

      local hooks = require("ibl.hooks")

      vim.g.rainbow_delimiters = { highlight = highlight }
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      require("ibl").setup({
         indent = { highlight = highlight },
         scope = {
            enabled = true,
            show_start = true,
            show_end = true,
            injected_languages = false,
            highlight = highlight,
            priority = 500,
         },
      })
   end,
}
