return {
   {
      "echasnovski/mini.icons",
      lazy = false,
      priority = 900,
      opts = {
         style = "glyph", -- "glyph" (Nerd Font) | "ascii"
      },
      config = function(_, opts)
         require("mini.icons").setup(opts)
         -- Mock nvim-web-devicons so every plugin that depends on it
         -- (nvim-tree, lualine, bufferline, telescope, trouble, snacks, etc.)
         -- transparently uses mini.icons instead — uniform, modern look.
         MiniIcons.mock_nvim_web_devicons()
      end,
   },
}
