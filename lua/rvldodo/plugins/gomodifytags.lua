return {
   "simondrake/gomodifytags",
   dependencies = { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
   vim.api.nvim_create_user_command("GoAddTags", function(opts)
      require("gomodifytags").GoAddTags(opts.fargs[1], opts.args)
   end, { nargs = "+" }),
   opts = {
      transformation = "snakecase",
      skip_unexported = true,
      override = true,
      options = { "json=omitempty" },
   },
}
