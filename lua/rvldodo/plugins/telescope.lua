return {
   "nvim-telescope/telescope.nvim",
   cmd = "Telescope", -- 🔥 lazy load
   keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>" },
      { "<leader>fs", "<cmd>Telescope live_grep<cr>" },
      { "<leader>fc", "<cmd>Telescope grep_string<cr>" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>" },
      { "<leader>fb", "<cmd>Telescope file_browser<cr>" },
   },
   dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
   },
   config = function()
      local telescope = require("telescope")

      telescope.setup({
         defaults = {
            vimgrep_arguments = {
               "rg",
               "-L",
               "--color=never",
               "--no-heading",
               "--with-filename",
               "--line-number",
               "--column",
               "--smart-case",
            },
            prompt_prefix = "   ",
            selection_caret = "   ",
            layout_strategy = "horizontal",
            layout_config = {
               horizontal = {
                  prompt_position = "top",
                  preview_width = 0.55,
               },
            },
            file_ignore_patterns = { "node_modules", ".git/" }, -- 🔥 added
         },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")
   end,
}
