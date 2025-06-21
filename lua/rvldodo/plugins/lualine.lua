return {
   "nvim-lualine/lualine.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
      local lualine = require("lualine")
      local lazy_status = require("lazy.status") -- lazy.nvim updates count

      -- Configure nvim-web-devicons for monochrome to match Cursor AI
      require("nvim-web-devicons").setup({
         color_icons = false, -- Disable colored icons for cleaner look
         default = true,
      })

      -- Cursor AI inspired colors
      local colors = {
         -- Main Cursor AI colors
         bg = "#0d1117", -- Main background
         bg_alt = "#161b22", -- Alternative background
         fg = "#e6edf3", -- Main text
         fg_alt = "#9ca3af", -- Secondary text

         -- Accent colors matching Cursor AI
         purple = "#a855f7", -- Functions and primary accent
         blue = "#3b82f6", -- Types and info
         green = "#22c55e", -- Success and strings
         yellow = "#eab308", -- Warnings
         orange = "#f97316", -- Keywords and numbers
         red = "#ef4444", -- Errors
         cyan = "#06b6d4", -- Special elements

         -- Status colors
         inactive_bg = "#21262d",
         border = "#6b7280",
      }

      -- Custom Cursor AI-inspired theme
      local cursor_ai_theme = {
         normal = {
            a = { bg = colors.purple, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg_alt, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg_alt },
         },
         insert = {
            a = { bg = colors.green, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg_alt, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg_alt },
         },
         visual = {
            a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg_alt, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg_alt },
         },
         command = {
            a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg_alt, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg_alt },
         },
         replace = {
            a = { bg = colors.red, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg_alt, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg_alt },
         },
         terminal = {
            a = { bg = colors.cyan, fg = colors.bg, gui = "bold" },
            b = { bg = colors.bg_alt, fg = colors.fg },
            c = { bg = colors.bg, fg = colors.fg_alt },
         },
         inactive = {
            a = { bg = colors.inactive_bg, fg = colors.fg_alt },
            b = { bg = colors.inactive_bg, fg = colors.fg_alt },
            c = { bg = colors.inactive_bg, fg = colors.fg_alt },
         },
      }

      -- Custom components for Cursor AI look
      local function get_file_icon()
         return ""
      end

      local function lsp_progress()
         local messages = vim.lsp.util.get_progress_messages()
         if #messages == 0 then
            return ""
         end
         local status = {}
         for _, msg in pairs(messages) do
            table.insert(status, (msg.percentage or 0) .. "%% " .. (msg.title or ""))
         end
         local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
         local ms = vim.loop.hrtime() / 1000000
         local frame = math.floor(ms / 120) % #spinners
         return table.concat(status, " | ") .. " " .. spinners[frame + 1]
      end

      -- Lualine configuration with Cursor AI styling
      lualine.setup({
         options = {
            theme = cursor_ai_theme,
            -- Cursor AI uses minimal separators
            section_separators = { left = "", right = "" },
            component_separators = { left = "│", right = "│" },
            globalstatus = true,
            icons_enabled = true,
            disabled_filetypes = {
               statusline = {},
               winbar = {},
            },
            refresh = {
               statusline = 1000,
               tabline = 1000,
               winbar = 1000,
            },
         },
         sections = {
            lualine_a = {
               {
                  "mode",
                  fmt = function(str)
                     -- Cursor AI style mode indicators
                     local mode_map = {
                        ["NORMAL"] = "●",
                        ["N-PENDING"] = "●",
                        ["INSERT"] = "✦",
                        ["VISUAL"] = "◆",
                        ["V-LINE"] = "◆",
                        ["V-BLOCK"] = "◆",
                        ["COMMAND"] = "▲",
                        ["REPLACE"] = "◉",
                        ["TERMINAL"] = "▣",
                     }
                     return mode_map[str] or str
                  end,
               },
            },
            lualine_b = {
               {
                  "branch",
                  icon = "",
                  color = { fg = colors.purple },
               },
               {
                  "diff",
                  symbols = { added = " ", modified = " ", removed = " " },
                  diff_color = {
                     added = { fg = colors.green },
                     modified = { fg = colors.blue },
                     removed = { fg = colors.red },
                  },
               },
            },
            lualine_c = {
               {
                  "filename",
                  path = 1,
                  symbols = {
                     modified = "●",
                     readonly = "",
                     unnamed = "[No Name]",
                     newfile = "[New]",
                  },
                  color = { fg = colors.fg },
               },
               {
                  lazy_status.updates,
                  cond = lazy_status.has_updates,
                  color = { fg = colors.orange },
                  fmt = function(str)
                     return " " .. str
                  end,
               },
               {
                  lsp_progress,
                  color = { fg = colors.cyan },
               },
            },
            lualine_x = {
               {
                  "diagnostics",
                  sources = { "nvim_diagnostic", "nvim_lsp" },
                  symbols = {
                     error = " ",
                     warn = " ",
                     info = " ",
                     hint = " ",
                  },
                  diagnostics_color = {
                     error = { fg = colors.red },
                     warn = { fg = colors.yellow },
                     info = { fg = colors.blue },
                     hint = { fg = colors.cyan },
                  },
               },
               {
                  "encoding",
                  fmt = function(str)
                     return str:upper()
                  end,
                  color = { fg = colors.fg_alt },
               },
               {
                  "fileformat",
                  icons_enabled = true,
                  color = { fg = colors.fg_alt },
               },
            },
            lualine_y = {
               {
                  "filetype",
                  colored = false,
                  icon_only = false,
                  color = { fg = colors.purple },
               },
               {
                  "progress",
                  color = { fg = colors.fg_alt },
               },
            },
            lualine_z = {
               {
                  "location",
                  fmt = function(str)
                     return " " .. str
                  end,
                  color = { fg = colors.fg },
               },
            },
         },
         inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
               {
                  "filename",
                  path = 1,
                  color = { fg = colors.fg_alt },
               },
            },
            lualine_x = {
               {
                  "location",
                  color = { fg = colors.fg_alt },
               },
            },
            lualine_y = {},
            lualine_z = {},
         },
         -- Cursor AI style tabline (optional)
         tabline = {},
         winbar = {},
         inactive_winbar = {},
         extensions = { "nvim-tree", "telescope", "quickfix", "fugitive" },
      })
   end,
}

