return {
   {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = {
         style = "moon", -- "storm" | "moon" | "night" | "day"
         transparent = true,
         terminal_colors = true,
         styles = {
            comments = { italic = true },
            keywords = { italic = true },
            functions = {},
            variables = {},
            sidebars = "transparent",
            floats = "transparent",
         },
         lualine_bold = true,
         on_highlights = function(hl, c)
            -- Slightly punchier borders & subtle line numbers for a clean look
            hl.FloatBorder = { fg = c.blue }
            hl.WinSeparator = { fg = c.bg_highlight }
            hl.LineNr = { fg = c.dark5 }
            hl.CursorLineNr = { fg = c.orange, bold = true }
         end,
      },
      config = function(_, opts)
         require("tokyonight").setup(opts)
         vim.cmd.colorscheme("tokyonight-moon")
      end,
   },

   -- Kept as a fallback/alt — uncomment the cmd.colorscheme line above and
   -- swap to one of these if you ever want to try another theme:
   -- {
   --    "catppuccin/nvim",
   --    name = "catppuccin",
   --    lazy = true,
   --    opts = { flavour = "mocha", transparent_background = true },
   -- },
   -- {
   --    "rose-pine/neovim",
   --    name = "rose-pine",
   --    lazy = true,
   --    opts = { variant = "main", styles = { transparency = true } },
   -- },
}
