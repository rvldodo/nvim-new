-- return {
--    "nvim-tree/nvim-tree.lua",
--    dependencies = "nvim-tree/nvim-web-devicons",
--    opts = {
--
--       filters = {
--          dotfiles = false,
--          exclude = { vim.fn.stdpath("config") .. "/lua/custom" },
--       },
--       disable_netrw = true,
--       hijack_netrw = true,
--       hijack_cursor = true,
--       hijack_unnamed_buffer_when_opening = false,
--       sync_root_with_cwd = true,
--       update_focused_file = {
--          enable = true,
--          update_root = false,
--       },
--       view = {
--          adaptive_size = false,
--          side = "left",
--          width = 30,
--          preserve_window_proportions = true,
--       },
--       git = {
--          enable = true,
--          ignore = false,
--       },
--       filesystem_watchers = {
--          enable = true,
--       },
--       actions = {
--          open_file = {
--             resize_window = true,
--          },
--       },
--       renderer = {
--          root_folder_label = false,
--          highlight_git = true,
--          highlight_opened_files = "none",
--
--          indent_markers = {
--             enable = false,
--          },
--
--          -- icons = {
--          --    show = {
--          --       file = true,
--          --       folder = true,
--          --       folder_arrow = true,
--          --       git = true,
--          --    },
--          --
--          --    glyphs = {
--          --       default = "󰈚",
--          --       symlink = "",
--          --       folder = {
--          --          default = "",
--          --          empty = "",
--          --          empty_open = "",
--          --          open = "",
--          --          symlink = "",
--          --          symlink_open = "",
--          --          arrow_open = "",
--          --          arrow_closed = "",
--          --       },
--          --       git = {
--          --          unstaged = "✗",
--          --          staged = "✓",
--          --          unmerged = "",
--          --          renamed = "➜",
--          --          untracked = "★",
--          --          deleted = "",
--          --          ignored = "◌",
--          --       },
--          --    },
--          -- },
--          icons = {
--             show = {
--                file = true,
--                folder = true,
--                folder_arrow = true,
--                git = true,
--             },
--             glyphs = {
--                default = "󰈚", -- Default file
--                symlink = "", -- Symlink file
--                folder = {
--                   default = "", -- Closed folder
--                   open = "", -- Open folder
--                   empty = "", -- Empty closed folder
--                   empty_open = "", -- Empty open folder
--                   symlink = "", -- Symlink folder
--                   symlink_open = "", -- Symlink folder open
--                   arrow_open = "", -- Arrow indicating open
--                   arrow_closed = "", -- Arrow indicating closed
--                },
--                git = {
--                   unstaged = "", -- Unstaged changes
--                   staged = "✓", -- Staged changes
--                   unmerged = "", -- Merge conflict
--                   renamed = "➜", -- Renamed file
--                   untracked = "★", -- Untracked files
--                   deleted = "", -- Deleted files
--                   ignored = "◌", -- Ignored files
--                },
--             },
--          },
--       },
--       -- diagnostics = {
--       --    enable = true,
--       --    show_on_dirs = true,
--       --    icons = {
--       --       hint = "",
--       --       info = "",
--       --       warning = "",
--       --       error = "",
--       --    },
--       -- },
--       diagnostics = {
--          enable = true,
--          show_on_dirs = true,
--          icons = {
--             hint = "󰌵", -- Hint icon
--             info = "󰙎", -- Info icon
--             warning = "", -- Warning icon
--             error = "", -- Error icon
--          },
--       },
--    },
--    config = function(_, opts)
--       local nvimtree = require("nvim-tree")
--
--       -- recommended settings from nvim-tree documentation
--       vim.g.loaded_netrw = 1
--       vim.g.loaded_netrwPlugin = 1
--
--       nvimtree.setup(opts)
--
--       -- set keymaps
--       local keymap = vim.keymap -- for conciseness
--
--       keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
--       keymap.set(
--          "n",
--          "<leader>ef",
--          "<cmd>NvimTreeFindFileToggle<CR>",
--          { desc = "Toggle file explorer on current file" }
--       ) -- toggle file explorer on current file
--       keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
--       keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
--    end,
-- }
--
return {
   "nvim-tree/nvim-tree.lua",
   dependencies = {
      "nvim-tree/nvim-web-devicons", -- Material icons will be loaded through this
   },
   opts = {
      filters = {
         dotfiles = false,
         exclude = { vim.fn.stdpath("config") .. "/lua/custom" },
         custom = { ".DS_Store" },
      },
      disable_netrw = true,
      hijack_netrw = true,
      hijack_cursor = true,
      hijack_unnamed_buffer_when_opening = false,
      sync_root_with_cwd = true,
      update_focused_file = {
         enable = true,
         update_root = false,
      },
      view = {
         adaptive_size = false,
         side = "left",
         width = 35,
         preserve_window_proportions = true,
         -- relativenumber = true,
      },
      git = {
         enable = false,
         ignore = false,
      },
      filesystem_watchers = {
         enable = false,
      },
      actions = {
         open_file = {
            resize_window = true,
         },
      },
      renderer = {
         root_folder_label = false,
         highlight_git = true,
         highlight_opened_files = "none",
         indent_markers = {
            -- enable = true,
            -- icons = {
            --    corner = "└",
            --    edge = "│",
            --    item = "│",
            --    none = " ",
            -- },
         },
         icons = {
            show = {
               file = true,
               folder = true,
               folder_arrow = true,
               git = true,
            },
            glyphs = {
               default = "󰈚", -- Default file
               symlink = "", -- Symlink file
               folder = {
                  default = "", -- Closed folder
                  open = "", -- Open folder
                  empty = "", -- Empty closed folder
                  empty_open = "", -- Empty open folder
                  symlink = "", -- Symlink folder
                  symlink_open = "", -- Symlink folder open
                  arrow_open = "", -- Arrow indicating open
                  arrow_closed = "", -- Arrow indicating closed
               },
               git = {
                  unstaged = "", -- Unstaged changes
                  staged = "✓", -- Staged changes
                  unmerged = "", -- Merge conflict
                  renamed = "➜", -- Renamed file
                  untracked = "★", -- Untracked files
                  deleted = "", -- Deleted files
                  ignored = "◌", -- Ignored files
               },
            },
         },
      },
      diagnostics = {
         enable = false,
         show_on_dirs = true,
         icons = {
            hint = "󰌵", -- Material design hint icon
            info = "󰋼", -- Material design info icon
            warning = "󰀪", -- Material design warning icon
            error = "󰅚", -- Material design error icon
         },
      },
   },
   config = function(_, opts)
      local nvimtree = require("nvim-tree")

      -- recommended settings from nvim-tree documentation
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      nvimtree.setup(opts)

      -- set keymaps
      local keymap = vim.keymap -- for conciseness
      keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
      keymap.set(
         "n",
         "<leader>ef",
         "<cmd>NvimTreeFindFileToggle<CR>",
         { desc = "Toggle file explorer on current file" }
      ) -- toggle file explorer on current file
      keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
      keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
   end,
}

-- return {
--    "nvim-tree/nvim-tree.lua",
--    cmd = { "NvimTreeToggle", "NvimTreeOpen" }, -- 🔥 lazy load
--    keys = {
--       { "<leader>ee", "<cmd>NvimTreeToggle<CR>" },
--       { "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>" },
--       { "<leader>ec", "<cmd>NvimTreeCollapse<CR>" },
--       { "<leader>er", "<cmd>NvimTreeRefresh<CR>" },
--    },
--    opts = {
--       filesystem_watchers = { enable = false },
--       git = { enable = false },
--       diagnostics = { enable = false },
--    },
-- }
