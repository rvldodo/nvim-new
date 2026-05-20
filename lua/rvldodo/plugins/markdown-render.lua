return {
   "MeanderingProgrammer/render-markdown.nvim",
   ft = { "markdown" },
   dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.icons",
   },
   ---@module "render-markdown"
   ---@type render.md.UserConfig
   opts = {
      file_types = { "markdown" },
      -- Render in every mode (default only renders in normal/command/terminal,
      -- so when you're typing in insert mode you'd see raw markdown and
      -- think the plugin isn't working).
      render_modes = true,
      heading = {
         sign = false,
         icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
      code = {
         sign = false,
         width = "block",
         right_pad = 1,
      },
      checkbox = {
         enabled = true,
      },
   },
}
