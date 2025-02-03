return {
   "nvim-telescope/telescope.nvim",
   branch = "0.1.x",
   dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-tree/nvim-web-devicons",
      "folke/todo-comments.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
   },
   config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = telescope.extensions.file_browser.actions

      telescope.setup({
         defaults = {
            -- preview = false,
            -- results_title = false,
            -- wrap_results = true,
            -- layout_config = { prompt_position = "top" },
            -- sorting_strategy = "ascending",
            -- layout_strategy = "vertical",
            -- border = true,
            -- path_display = { "truncate" },
            -- mappings = {
            --    i = {
            --       ["<C-k>"] = actions.move_selection_previous, -- move to prev result
            --       ["<C-j>"] = actions.move_selection_next, -- move to next result
            --       ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            --    },
            -- },

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
            entry_prefix = "  ",
            initial_mode = "insert",
            selection_strategy = "reset",
            sorting_strategy = "ascending",
            layout_strategy = "horizontal",
            layout_config = {
               horizontal = {
                  prompt_position = "top",
                  preview_width = 0.55,
                  results_width = 0.8,
               },
               vertical = {
                  mirror = false,
               },
               width = 0.87,
               height = 0.80,
               preview_cutoff = 120,
            },
            file_sorter = require("telescope.sorters").get_fuzzy_file,
            file_ignore_patterns = { "node_modules" },
            generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
            path_display = { "truncate" },
            winblend = 0,
            border = {},
            borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
            color_devicons = true,
            set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
            file_previewer = require("telescope.previewers").vim_buffer_cat.new,
            grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
            qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
            -- Developer configurations: Not meant for general override
            buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
            mappings = {
               i = {
                  ["<C-n>"] = actions.cycle_history_next,
                  ["<C-p>"] = actions.cycle_history_prev,

                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,

                  ["<C-c>"] = actions.close,

                  ["<Down>"] = actions.move_selection_next,
                  ["<Up>"] = actions.move_selection_previous,

                  ["<CR>"] = actions.select_default,
                  ["<C-x>"] = actions.select_horizontal,
                  ["<C-v>"] = actions.select_vertical,
                  ["<C-t>"] = actions.select_tab,

                  ["<C-u>"] = actions.preview_scrolling_up,
                  ["<C-d>"] = actions.preview_scrolling_down,

                  ["<PageUp>"] = actions.results_scrolling_up,
                  ["<PageDown>"] = actions.results_scrolling_down,

                  ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                  ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                  ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                  ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                  ["<C-l>"] = actions.complete_tag,
                  -- ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
               },

               n = {
                  ["<q>"] = actions.close,
                  ["<CR>"] = actions.select_default,
                  ["<C-x>"] = actions.select_horizontal,
                  ["<C-v>"] = actions.select_vertical,
                  ["<C-t>"] = actions.select_tab,

                  ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                  ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                  ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                  ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                  ["j"] = actions.move_selection_next,
                  ["k"] = actions.move_selection_previous,
                  ["H"] = actions.move_to_top,
                  ["M"] = actions.move_to_middle,
                  ["L"] = actions.move_to_bottom,

                  ["<Down>"] = actions.move_selection_next,
                  ["<Up>"] = actions.move_selection_previous,
                  ["gg"] = actions.move_to_top,
                  ["G"] = actions.move_to_bottom,

                  ["<C-u>"] = actions.preview_scrolling_up,
                  ["<C-d>"] = actions.preview_scrolling_down,

                  ["<PageUp>"] = actions.results_scrolling_up,
                  ["<PageDown>"] = actions.results_scrolling_down,

                  ["?"] = actions.which_key,
               },
            },
         },
         pickers = {
            diagnostics = {
               theme = "ivy",
               initial_mode = "normal",
               layout_config = {
                  preview_cutoff = 9999,
               },
            },
            planets = {
               show_pluto = true,
            },
         },
         extensions_list = {
            "themes",
            "terms",
            file_browser = {
               path = "%:p:h", -- open from within the folder of your current buffer
               display_stat = false, -- don't show file stat
               grouped = true, -- group initial sorting by directories and then files
               hidden = true, -- show hidden files
               hide_parent_dir = true, -- hide `../` in the file browser
               hijack_netrw = true, -- use telescope file browser when opening directory paths
               prompt_path = true, -- show the current relative path from cwd as the prompt prefix
               use_fd = true, -- use `fd` instead of plenary, make sure to install `fd`
            },
         },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("file_browser")

      -- set keymaps
      local keymap = vim.keymap -- for conciseness

      keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
      keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
      keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
      keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
      keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
      keymap.set("n", "<leader>fb", ":Telescope file_browser<cr>", { desc = "Find file browser" })
      keymap.set("n", "<leader>fr", function()
         require("telescope.builtin").grep_string({
            search = vim.fn.input("Find: "),
         })
      end, { desc = "Find and replace in cwd" })
   end,
}

-- return {
--    "telescope.nvim",
--    dependencies = {
--       {
--          "nvim-telescope/telescope-fzf-native.nvim",
--          build = "make",
--       },
--       "nvim-telescope/telescope-file-browser.nvim",
--    },
--    keys = {
--       {
--          "<leader>ff",
--          function()
--             require("telescope.builtin").find_files({
--                cwd = require("lazy.core.config").options.root,
--             })
--          end,
--          desc = "Find Plugin File",
--       },
--       {
--          ";f",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.find_files({
--                no_ignore = false,
--                hidden = true,
--             })
--          end,
--          desc = "Lists files in your current working directory, respects .gitignore",
--       },
--       {
--          "<leader>fs",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.live_grep({
--                additional_args = { "--hidden" },
--             })
--          end,
--          desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
--       },
--       {
--          "\\\\",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.buffers()
--          end,
--          desc = "Lists open buffers",
--       },
--       {
--          ";t",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.help_tags()
--          end,
--          desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
--       },
--       {
--          ";;",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.resume()
--          end,
--          desc = "Resume the previous telescope picker",
--       },
--       {
--          ";e",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.diagnostics()
--          end,
--          desc = "Lists Diagnostics for all open buffers or a specific buffer",
--       },
--       {
--          ";s",
--          function()
--             local builtin = require("telescope.builtin")
--             builtin.treesitter()
--          end,
--          desc = "Lists Function names, variables, from Treesitter",
--       },
--       {
--          "sf",
--          function()
--             local telescope = require("telescope")
--
--             local function telescope_buffer_dir()
--                return vim.fn.expand("%:p:h")
--             end
--
--             telescope.extensions.file_browser.file_browser({
--                path = "%:p:h",
--                cwd = telescope_buffer_dir(),
--                respect_gitignore = false,
--                hidden = true,
--                grouped = true,
--                previewer = false,
--                initial_mode = "normal",
--                layout_config = { height = 40 },
--             })
--          end,
--          desc = "Open File Browser with the path of the current buffer",
--       },
--    },
--    config = function(_, opts)
--       local telescope = require("telescope")
--       local actions = require("telescope.actions")
--       local fb_actions = require("telescope").extensions.file_browser.actions
--
--       opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
--          wrap_results = true,
--          layout_strategy = "horizontal",
--          layout_config = { prompt_position = "top" },
--          sorting_strategy = "ascending",
--          winblend = 0,
--          mappings = {
--             n = {},
--          },
--       })
--       opts.pickers = {
--          diagnostics = {
--             theme = "ivy",
--             initial_mode = "normal",
--             layout_config = {
--                preview_cutoff = 9999,
--             },
--          },
--       }
--       opts.extensions = {
--          file_browser = {
--             theme = "dropdown",
--             -- disables netrw and use telescope-file-browser in its place
--             hijack_netrw = true,
--             mappings = {
--                -- your custom insert mode mappings
--                ["n"] = {
--                   -- your custom normal mode mappings
--                   ["N"] = fb_actions.create,
--                   ["h"] = fb_actions.goto_parent_dir,
--                   ["/"] = function()
--                      vim.cmd("startinsert")
--                   end,
--                   ["<C-u>"] = function(prompt_bufnr)
--                      for i = 1, 10 do
--                         actions.move_selection_previous(prompt_bufnr)
--                      end
--                   end,
--                   ["<C-d>"] = function(prompt_bufnr)
--                      for i = 1, 10 do
--                         actions.move_selection_next(prompt_bufnr)
--                      end
--                   end,
--                   ["<PageUp>"] = actions.preview_scrolling_up,
--                   ["<PageDown>"] = actions.preview_scrolling_down,
--                },
--             },
--          },
--       }
--       telescope.setup(opts)
--       require("telescope").load_extension("fzf")
--       require("telescope").load_extension("file_browser")
--    end,
-- }
