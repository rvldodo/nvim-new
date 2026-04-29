return {
   -- Cursor AI-inspired theme configuration
   -- {
   --    "navarasu/onedark.nvim",
   --    priority = 1000,
   --    opts = {
   --       style = "darker",
   --       transparent = true,
   --       term_colors = true,
   --       ending_tildes = false,
   --
   --       -- Softened color palette
   --       colors = {
   --          bg0 = "#0f1218", -- Slightly lighter main background
   --          bg1 = "#181d24", -- Softer secondary background
   --          bg2 = "#22272e", -- Muted tertiary background
   --          bg3 = "#282e38", -- Soft selection background
   --          bg_d = "#0f1218", -- Dark background
   --          bg_blue = "#1a3d8c", -- Muted blue background
   --          bg_yellow = "#f7c46c", -- Softer warning background
   --          fg = "#e8eef5", -- Soft main foreground text
   --          purple = "#b07feb", -- Muted purple
   --          green = "#4cc38a", -- Softer green
   --          orange = "#f78e65", -- Muted orange
   --          blue = "#5d9bf8", -- Soft blue
   --          yellow = "#f0c674", -- Muted yellow
   --          cyan = "#5dc4d4", -- Soft cyan
   --          red = "#f07178", -- Muted red
   --          grey = "#7a828e", -- Softer comments
   --          light_grey = "#a5adba", -- Muted inactive text
   --          dark_cyan = "#3d9db2", -- Softer dark cyan
   --          dark_red = "#d44f54", -- Muted dark red
   --          dark_yellow = "#d4a240", -- Softer dark yellow
   --          dark_purple = "#9a5eeb", -- Muted dark purple
   --          diff_add = "#4cc38a", -- Soft git additions
   --          diff_delete = "#f07178", -- Soft git deletions
   --          diff_change = "#5d9bf8", -- Soft git changes
   --          diff_text = "#2a4cb3", -- Muted git text changes
   --       },
   --
   --       code_style = {
   --          comments = "italic",
   --          keywords = "bold",
   --          functions = "bold",
   --          strings = "none",
   --          variables = "none",
   --       },
   --
   --       highlights = {
   --          ["Normal"] = { fg = "#e8eef5", bg = "NONE" },
   --          ["NormalNC"] = { fg = "#e8eef5", bg = "NONE" },
   --          ["CursorLine"] = { bg = "#181d2433" }, -- More transparent
   --          ["CursorLineNr"] = { fg = "#b07feb", bold = true },
   --          ["LineNr"] = { fg = "#7a828e" },
   --          ["SignColumn"] = { bg = "NONE" },
   --          -- Enhanced Visual Selection Highlighting
   --          ["Visual"] = { bg = "#3d4c63", fg = "#ffffff" }, -- More prominent selection
   --          ["VisualNOS"] = { bg = "#3d4c63", fg = "#ffffff" }, -- Non-owning selection
   --          ["VisualLine"] = { bg = "#3d4c63", fg = "#ffffff" }, -- Line-wise selection
   --          ["VisualBlock"] = { bg = "#2d4f73", fg = "#ffffff" }, -- Block-wise selection
   --
   --          ["@function"] = { fg = "#b07feb", bold = true },
   --          ["@function.call"] = { fg = "#b07feb" },
   --          ["@method"] = { fg = "#b07feb", bold = true },
   --          ["@keyword"] = { fg = "#f78e65", bold = true },
   --          ["@keyword.function"] = { fg = "#f78e65", bold = true },
   --          ["@keyword.return"] = { fg = "#f78e65", bold = true },
   --          ["@string"] = { fg = "#4cc38a" },
   --          ["@string.escape"] = { fg = "#5dc4d4" },
   --          ["@comment"] = { fg = "#7a828e", italic = true },
   --          ["@variable"] = { fg = "#e8eef5" },
   --          ["@variable.builtin"] = { fg = "#5d9bf8" },
   --          ["@constant"] = { fg = "#f0c674" },
   --          ["@constant.builtin"] = { fg = "#f0c674" },
   --          ["@number"] = { fg = "#f78e65" },
   --          ["@boolean"] = { fg = "#f78e65" },
   --          ["@type"] = { fg = "#5d9bf8" },
   --          ["@type.builtin"] = { fg = "#5d9bf8" },
   --          ["@operator"] = { fg = "#5dc4d4" },
   --          ["@punctuation"] = { fg = "#a5adba" },
   --
   --          ["Pmenu"] = { fg = "#e8eef5", bg = "#181d2477" },
   --          ["PmenuSel"] = { fg = "#e8eef5", bg = "#22272eaa" },
   --          ["PmenuSbar"] = { bg = "#22272e77" },
   --          ["PmenuThumb"] = { bg = "#7a828e" },
   --          ["StatusLine"] = { fg = "#e8eef5", bg = "#181d24aa" },
   --          ["StatusLineNC"] = { fg = "#7a828e", bg = "#181d24aa" },
   --          ["TabLine"] = { fg = "#7a828e", bg = "#181d24aa" },
   --          ["TabLineFill"] = { bg = "#181d24aa" },
   --          ["TabLineSel"] = { fg = "#e8eef5", bg = "#0f1218aa" },
   --
   --          ["NormalFloat"] = { fg = "#e8eef5", bg = "#181d24aa" },
   --          ["FloatBorder"] = { fg = "#7a828e", bg = "#181d24aa" },
   --          ["FloatTitle"] = { fg = "#b07feb", bg = "#181d24aa", bold = true },
   --
   --          ["Search"] = { fg = "#0f1218", bg = "#f0c674" },
   --          ["IncSearch"] = { fg = "#0f1218", bg = "#f78e65" },
   --          ["CurSearch"] = { fg = "#0f1218", bg = "#f78e65" },
   --
   --          ["GitSignsAdd"] = { fg = "#4cc38a" },
   --          ["GitSignsChange"] = { fg = "#5d9bf4" },
   --          ["GitSignsDelete"] = { fg = "#f07178" },
   --
   --          ["DiagnosticError"] = { fg = "#f07178" },
   --          ["DiagnosticWarn"] = { fg = "#f0c674" },
   --          ["DiagnosticInfo"] = { fg = "#5d9bf8" },
   --          ["DiagnosticHint"] = { fg = "#5dc4d4" },
   --          ["DiagnosticVirtualTextError"] = { fg = "#f07178", bg = "#1f121433" },
   --          ["DiagnosticVirtualTextWarn"] = { fg = "#f0c674", bg = "#1f1b1333" },
   --          ["DiagnosticVirtualTextInfo"] = { fg = "#5d9bf8", bg = "#0f141933" },
   --          ["DiagnosticVirtualTextHint"] = { fg = "#5dc4d4", bg = "#0f1a1c33" },
   --
   --          ["TelescopeNormal"] = { fg = "#e8eef5", bg = "#181d24aa" },
   --          ["TelescopeBorder"] = { fg = "#7a828e", bg = "#181d24aa" },
   --          ["TelescopeTitle"] = { fg = "#b07feb", bold = true },
   --          ["TelescopeSelection"] = { fg = "#e8eef5", bg = "#22272eaa" },
   --          ["TelescopeSelectionCaret"] = { fg = "#b07feb" },
   --          ["TelescopeMatching"] = { fg = "#f0c674", bold = true },
   --
   --          ["TreesitterContext"] = { bg = "#181d2433" },
   --          ["TreesitterContextLineNumber"] = { fg = "#7a828e", bg = "#181d2433" },
   --
   --          ["WhichKey"] = { fg = "#b07feb" },
   --          ["WhichKeyGroup"] = { fg = "#5d9bf8" },
   --          ["WhichKeyDesc"] = { fg = "#e8eef5" },
   --          ["WhichKeySeperator"] = { fg = "#7a828e" },
   --          ["WhichKeyFloat"] = { bg = "#181d24aa" },
   --          ["WhichKeyBorder"] = { fg = "#7a828e", bg = "#181d24aa" },
   --       },
   --
   --       diagnostics = {
   --          darker = false,
   --          undercurl = true,
   --          background = true,
   --       },
   --    },
   --    config = function(_, opts)
   --       require("onedark").setup(opts)
   --       vim.cmd.colorscheme("onedark")
   --
   --       vim.cmd([[
   --          highlight Cursor guifg=#0f1218 guibg=#b07feb
   --          highlight CursorIM guifg=#0f1218 guibg=#b07feb
   --
   --          highlight Folded guifg=#7a828e guibg=#181d2433
   --          highlight FoldColumn guifg=#7a828e guibg=NONE
   --
   --          highlight DiffAdd guifg=#4cc38a guibg=#0f1b1333
   --          highlight DiffChange guifg=#5d9bf8 guibg=#0f141933
   --          highlight DiffDelete guifg=#f07178 guibg=#1f121433
   --          highlight DiffText guifg=#2a4cb3 guibg=#1a3d8c33
   --
   --          let g:terminal_color_0  = '#0f1218'
   --          let g:terminal_color_1  = '#f07178'
   --          let g:terminal_color_2  = '#4cc38a'
   --          let g:terminal_color_3  = '#f0c674'
   --          let g:terminal_color_4  = '#5d9bf8'
   --          let g:terminal_color_5  = '#b07feb'
   --          let g:terminal_color_6  = '#5dc4d4'
   --          let g:terminal_color_7  = '#e8eef5'
   --          let g:terminal_color_8  = '#7a828e'
   --          let g:terminal_color_9  = '#f88f94'
   --          let g:terminal_color_10 = '#6bd49e'
   --          let g:terminal_color_11 = '#f8d684'
   --          let g:terminal_color_12 = '#7daffa'
   --          let g:terminal_color_13 = '#c09ff1'
   --          let g:terminal_color_14 = '#7dd4e4'
   --          let g:terminal_color_15 = '#f9fafc'
   --       ]])
   --    end,
   -- },
   -- Alternative: Pure Cursor AI theme using a more minimal approach
   -- Uncomment this if you prefer a cleaner setup
   {
      "folke/tokyonight.nvim",
      priority = 1000,
      opts = {
         style = "moon",
         transparent = true,
         terminal_colors = false,
         styles = {
            comments = { italic = true },
            keywords = { bold = true },
            functions = { bold = true },
            variables = {},
            -- Make sidebars and floats transparent
            sidebars = "transparent",
            floats = "transparent",
         },
         -- Override specific colors to be transparent
         on_colors = function(colors)
            colors.bg = "NONE"
            colors.bg_dark = "NONE"
            colors.bg_float = "NONE"
            colors.bg_sidebar = "NONE"
         end,
         on_highlights = function(highlights, colors)
            -- Make tree/sidebar backgrounds transparent
            highlights.NvimTreeNormal = { bg = "NONE" }
            highlights.NvimTreeNormalNC = { bg = "NONE" }
            highlights.NvimTreeEndOfBuffer = { bg = "NONE" }
            highlights.NeoTreeNormal = { bg = "NONE" }
            highlights.NeoTreeNormalNC = { bg = "NONE" }
            highlights.NeoTreeEndOfBuffer = { bg = "NONE" }
         end,
      },
      config = function(_, opts)
         require("tokyonight").setup(opts)
         vim.cmd.colorscheme("tokyonight-moon")

         -- Additional transparency overrides
         vim.cmd([[
         " Ensure everything is transparent
         highlight Normal guibg=NONE ctermbg=NONE
         highlight NormalNC guibg=NONE ctermbg=NONE
         highlight SignColumn guibg=NONE ctermbg=NONE
         highlight VertSplit guibg=NONE ctermbg=NONE
         highlight EndOfBuffer guibg=NONE ctermbg=NONE
         
         " File tree transparency (nvim-tree)
         highlight NvimTreeNormal guibg=NONE ctermbg=NONE
         highlight NvimTreeNormalNC guibg=NONE ctermbg=NONE
         highlight NvimTreeEndOfBuffer guibg=NONE ctermbg=NONE
         highlight NvimTreeWinSeparator guibg=NONE ctermbg=NONE
         
         " File tree transparency (neo-tree)
         highlight NeoTreeNormal guibg=NONE ctermbg=NONE
         highlight NeoTreeNormalNC guibg=NONE ctermbg=NONE
         highlight NeoTreeEndOfBuffer guibg=NONE ctermbg=NONE
         highlight NeoTreeWinSeparator guibg=NONE ctermbg=NONE
         
         " Telescope transparency
         highlight TelescopeNormal guibg=NONE ctermbg=NONE
         highlight TelescopeBorder guibg=NONE ctermbg=NONE
         
         " Floating windows transparency
         highlight NormalFloat guibg=NONE ctermbg=NONE
         highlight FloatBorder guibg=NONE ctermbg=NONE
      ]])
      end,
   },
   -- {
   --    "cpea2506/one_monokai.nvim",
   --    opts = {
   --       transparent = true,
   --       colors = {},
   --       italics = true,
   --    },
   --    config = function(_, opts)
   --       require("one_monokai").setup(opts)
   --       vim.cmd([[colorscheme one_monokai]])
   --    end,
   -- },
}
