return {
   "epwalsh/obsidian.nvim",
   version = "*",
   lazy = true,
   ft = "markdown",
   dependencies = {
      "nvim-lua/plenary.nvim",
   },
   opts = {
      workspaces = {
         {
            name = "notes",
            path = "~/projects/notes",
         },
         {
            name = "woori",
            path = "~/projects/notes/woori",
         },
      },

      daily_notes = {
         folder = "daily",
         date_format = "%Y-%m-%d",
      },
   },
}
