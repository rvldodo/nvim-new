return {
   -- "echasnovski/mini.hipatterns",
   -- event = "BufReadPre",
   -- opts = {},

   "norcalli/nvim-colorizer.lua",
   event = "BufReadPre",
   config = function()
      require("colorizer").setup() -- Default setup
   end,
}
