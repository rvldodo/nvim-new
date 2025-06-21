-- Global monochrome icon configuration
-- This file ensures all icons across Neovim are displayed in monochrome

return {
   "nvim-tree/nvim-web-devicons",
   config = function()
      -- Configure nvim-web-devicons globally for monochrome
      require('nvim-web-devicons').setup({
         color_icons = false, -- Disable colored icons globally
         default = true,
         override = {
            -- Force all icons to use Normal highlight group for monochrome
         },
      })
      
      -- Force all devicon highlight groups to use Normal highlighting
      local function force_monochrome_devicons()
         local devicons = require('nvim-web-devicons')
         local icons = devicons.get_icons()
         for name, icon_data in pairs(icons) do
            if icon_data.color then
               vim.api.nvim_set_hl(0, 'DevIcon' .. icon_data.name, { link = 'Normal' })
            end
         end
      end
      
      -- Apply monochrome devicons immediately
      vim.defer_fn(force_monochrome_devicons, 100)

      -- Create an autocmd to ensure monochrome icons persist after colorscheme changes
      vim.api.nvim_create_autocmd("ColorScheme", {
         pattern = "*",
         callback = function()
            -- Re-setup nvim-web-devicons to ensure monochrome after colorscheme change
            require('nvim-web-devicons').setup({
               color_icons = false,
               default = true,
            })
            
            -- Force all devicon highlight groups to monochrome
            vim.defer_fn(force_monochrome_devicons, 50)
            
            -- Also ensure mini.icons colors are neutralized
            local mini_icon_groups = {
               "MiniIconsAzure",
               "MiniIconsBlue", 
               "MiniIconsCyan",
               "MiniIconsGreen",
               "MiniIconsGrey",
               "MiniIconsOrange",
               "MiniIconsPurple",
               "MiniIconsRed",
               "MiniIconsYellow",
            }
            
            for _, group in ipairs(mini_icon_groups) do
               vim.api.nvim_set_hl(0, group, { link = "Normal" })
            end
         end,
      })

      -- Trigger the autocmd for the current colorscheme
      vim.cmd('doautocmd ColorScheme')
   end,
}
