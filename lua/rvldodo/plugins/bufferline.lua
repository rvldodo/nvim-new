return {
   "akinsho/bufferline.nvim",
   dependencies = { "nvim-tree/nvim-web-devicons" },
   version = "*",
   config = function()
      -- Configure nvim-web-devicons for monochrome in bufferline
      require("nvim-web-devicons").setup({
         color_icons = false,
         default = true,
      })

      require("bufferline").setup({
         options = {
            mode = "tabs",
            separator_style = "slant",
            show_buffer_icons = true,
            show_buffer_close_icons = false,
            show_close_icon = false,
            color_icons = false, -- Disable colored icons
         },
      })
   end,
}
