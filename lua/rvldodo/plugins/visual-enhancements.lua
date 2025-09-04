return {
   -- Add visual selection improvements
   {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
         -- Enhance visual selections with treesitter
         opts.textobjects = opts.textobjects or {}
         opts.textobjects.select = opts.textobjects.select or {}
         opts.textobjects.select.enable = true
         opts.textobjects.select.lookahead = true
         opts.textobjects.select.keymaps = opts.textobjects.select.keymaps or {
            -- Visual selection textobjects
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["ab"] = "@block.outer",
            ["ib"] = "@block.inner",
         }
         return opts
      end,
   },

   -- Visual selection highlighting improvements
   {
      "RRethy/vim-illuminate",
      config = function()
         require("illuminate").configure({
            providers = {
               "lsp",
               "treesitter",
               "regex",
            },
            delay = 100,
            filetypes_denylist = {
               "dirvish",
               "fugitive",
               "NvimTree",
               "trouble",
            },
            under_cursor = true,
            case_insensitive_regex = false,
            large_file_cutoff = nil,
            large_file_overrides = nil,
            min_count_to_highlight = 1,
         })

         -- Custom highlight groups for illuminate
         vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#3d4c63", underline = false })
         vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#3d4c63", underline = false })
         vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#4a5c73", underline = false })

         -- Keymaps for illuminate
         vim.keymap.set("n", "<leader>vn", require("illuminate").goto_next_reference, { desc = "Next reference" })
         vim.keymap.set("n", "<leader>vp", require("illuminate").goto_prev_reference, { desc = "Previous reference" })
         vim.keymap.set("n", "<leader>vi", require("illuminate").toggle, { desc = "Toggle illuminate" })
      end,
   },
}
