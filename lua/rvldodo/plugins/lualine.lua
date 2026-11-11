return {
   "nvim-lualine/lualine.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   config = function()
      local lualine = require("lualine")
      local lazy_status = require("lazy.status") -- lazy.nvim updates count

      local colors = {
         blue = "#65D1FF",
         green = "#3EFFDC",
         violet = "#FF61EF",
         yellow = "#FFDA7B",
         red = "#FF4A4A",
         fg = "#c3ccdc",
         bg = "#112638",
         inactive_bg = "#2c3043",
      }

      -- Custom theme inspired by Cursor
      local my_lualine_theme = {
         normal = {
            a = { bg = colors.blue, fg = colors.bg, gui = "bold" },
            b = { bg = "NONE", fg = colors.fg },
            c = { bg = "NONE", fg = colors.fg },
         },
         insert = {
            a = { bg = colors.green, fg = colors.bg, gui = "bold" },
            b = { bg = "NONE", fg = colors.fg },
            c = { bg = "NONE", fg = colors.fg },
         },
         visual = {
            a = { bg = colors.violet, fg = colors.bg, gui = "bold" },
            b = { bg = "NONE", fg = colors.fg },
            c = { bg = "NONE", fg = colors.fg },
         },
         command = {
            a = { bg = colors.yellow, fg = colors.bg, gui = "bold" },
            b = { bg = "NONE", fg = colors.fg },
            c = { bg = "NONE", fg = colors.fg },
         },
         replace = {
            a = { bg = colors.red, fg = colors.bg, gui = "bold" },
            b = { bg = "NONE", fg = colors.fg },
            c = { bg = "NONE", fg = colors.fg },
         },
         inactive = {
            a = { bg = "NONE", fg = colors.fg, gui = "bold" },
            b = { bg = "NONE", fg = colors.fg },
            c = { bg = "NONE", fg = colors.fg },
         },
      }

      -- Lualine configuration
      lualine.setup({
         options = {
            theme = my_lualine_theme,
            section_separators = { left = "", right = "" },
            component_separators = { left = "", right = "" },
            globalstatus = true,
         },
         sections = {
            lualine_a = { { "mode", icon = "" } },
            lualine_b = { { "branch", icon = "" }, "diff" },
            lualine_c = {
               { "filename", path = 1, symbols = { modified = " ", readonly = " " } },
               { lazy_status.updates, cond = lazy_status.has_updates, color = { fg = colors.yellow } },
            },
            lualine_x = {
               -- Active dbee connection (set in plugins/nvim-dbee.lua).
               {
                  function()
                     local a = vim.g.dbee_active
                     local text = a.icon .. " " .. a.name .. (a.database and (":" .. a.database) or "")
                     return a.prod and (text .. " PROD") or text
                  end,
                  cond = function() return vim.g.dbee_active ~= nil end,
                  color = function()
                     local a = vim.g.dbee_active or {}
                     if a.prod then
                        return { fg = colors.bg, bg = colors.red, gui = "bold" }
                     end
                     return { fg = a.color, gui = "bold" }
                  end,
               },
               "diagnostics",
               "encoding",
               "fileformat",
               "filetype",
            },
            lualine_y = { "progress" },
            lualine_z = { { "location", icon = "" } },
         },
         inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
         },
      })
   end,
}
