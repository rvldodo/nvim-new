return {
   "nvim-pack/nvim-spectre",
   config = function()
      local spectre = require("spectre")

      -- Search and replace in current file
      vim.keymap.set("n", "<leader>sw", function()
         spectre.open_visual({ select_word = true })
      end, { desc = "Search current word" })

      -- Search and replace globally
      vim.keymap.set("n", "<leader>sg", spectre.open, { desc = "Search globally" })
   end,
}
