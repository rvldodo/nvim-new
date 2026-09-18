return {
   "mistricky/codesnap.nvim",
   -- No build step: v2.x downloads a prebuilt native generator on first load
   -- (cached at lua/libs/<os>-<arch>_generator.so). The old
   -- `make build_generator` target compiled a lib the v2 loader never reads.
   cmd = { "CodeSnap", "CodeSnapSave", "CodeSnapASCII" },
   opts = {
      show_line_number = true,
      snapshot_config = {
         code_config = {
            breadcrumbs = { enable = true },
         },
         watermark = { content = "" },

         -- v2 equivalent of v1's bg_padding = 0: remove the padding
         -- around the card so the green no longer shows
         window_config = {
            margin = { x = 0, y = 0 },
         },

         -- optional: make the surround transparent instead of the gradient
         background = {
            start = { x = 0, y = 0 },
            ["end"] = { x = "max", y = "max" },
            stops = {
               { position = 0, color = "#00000000" },
               { position = 1, color = "#00000000" },
            },
         },
      },
   },
   keys = {
      { "<leader>cc", "<cmd>CodeSnap<cr>", mode = "x", desc = "Copy snapshot to clipboard" },
      {
         "<leader>cs",
         function()
            -- v2 requires an explicit .png path; write a timestamped file
            -- into ~/Pictures/codesnap (created if missing).
            local dir = vim.fn.expand("~/Pictures/codesnap")
            vim.fn.mkdir(dir, "p")
            local path = dir .. "/CodeSnap-" .. os.date("%Y-%m-%d-%H%M%S") .. ".png"
            vim.cmd("CodeSnapSave " .. vim.fn.fnameescape(path))
         end,
         mode = "x",
         desc = "Save snapshot to file",
      },
   },
}
