return {
   -- {
   --   "navarasu/onedark.nvim",
   --   opts = {
   --     -- Main options --
   --     style = "deep", -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
   --     transparent = true, -- Show/hide background
   --     term_colors = true, -- Change terminal color as per the selected theme style
   --     ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
   --     cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu
   --
   --     -- toggle theme style ---
   --     toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
   --     toggle_style_list = { "dark", "darker", "cool", "deep", "warm", "warmer", "light" }, -- List of styles to toggle between
   --
   --     -- Change code style ---
   --     -- Options are italic, bold, underline, none
   --     -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
   --     code_style = {
   --       comments = "italic",
   --       keywords = "none",
   --       functions = "none",
   --       strings = "none",
   --       variables = "none",
   --     },
   --
   --     -- Lualine options --
   --     lualine = {
   --       transparent = false, -- lualine center bar transparency
   --     },
   --
   --     -- Custom Highlights --
   --     colors = {}, -- Override default colors
   --     highlights = {}, -- Override highlight groups
   --
   --     -- Plugins Config --
   --     diagnostics = {
   --       darker = true, -- darker colors for diagnostic
   --       undercurl = true, -- use undercurl instead of underline for diagnostics
   --       background = true, -- use background color for virtual text
   --     },
   --   },
   --   -- Lua
   --   config = function(_, opts)
   --     require("onedark").setup(opts)
   --     vim.cmd([[colorscheme onedark]])
   --   end,
   -- },
   -- {
   --   "zootedb0t/citruszest.nvim",
   --   lazy = false,
   --   priority = 1000,
   --   opts = {
   --     option = {
   --       transparent = true, -- Enable/Disable transparency
   --       bold = false,
   --       italic = true,
   --     },
   --     -- Override default highlight style in this table
   --     -- E.g If you want to override `Constant` highlight style
   --     style = {
   --       -- This will change Constant foreground color and make it bold.
   --       Constant = { fg = "#FFFFFF", bold = true },
   --     },
   --   },
   --   config = function(_, opts)
   --     require("citruszest").setup(opts)
   --     vim.cmd([[colorscheme citruszest]])
   --   end,
   -- },
   {
      "cpea2506/one_monokai.nvim",
      opts = {
         transparent = true,
         colors = {},
         italics = true,
      },
      config = function(_, opts)
         require("one_monokai").setup(opts)
         vim.cmd([[colorscheme one_monokai]])
      end,
   },
   -- {
   --    "craftzdog/solarized-osaka.nvim",
   --    lazy = true,
   --    priority = 1000,
   --    opts = function()
   --       return {
   --          transparent = true,
   --       }
   --    end,
   -- },
   -- {
   --    "sainnhe/sonokai",
   --    priority = 1000,
   --    config = function()
   --       vim.g.sonokai_transparent_background = "1"
   --       vim.g.sonokai_enable_italic = "1"
   --       vim.g.sonokai_style = "andromeda"
   --       vim.cmd.colorscheme("sonokai")
   --    end,
   -- },
   -- {
   --    "ellisonleao/gruvbox.nvim",
   --    priority = 1000,
   --    config = function()
   --       require("gruvbox").setup({
   --          terminal_colors = true, -- add neovim terminal colors
   --          undercurl = true,
   --          underline = true,
   --          bold = true,
   --          italic = {
   --             strings = true,
   --             emphasis = true,
   --             comments = true,
   --             operators = false,
   --             folds = true,
   --          },
   --          strikethrough = true,
   --          invert_selection = false,
   --          invert_signs = false,
   --          invert_tabline = false,
   --          invert_intend_guides = false,
   --          inverse = true, -- invert background for search, diffs, statuslines and errors
   --          contrast = "", -- can be "hard", "soft" or empty string
   --          palette_overrides = {},
   --          overrides = {},
   --          dim_inactive = false,
   --          transparent_mode = true,
   --       })
   --       vim.cmd("colorscheme gruvbox")
   --    end,
   -- },
}
