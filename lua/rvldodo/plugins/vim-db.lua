-- Define sql filetypes at the top
local sql_ft = { "sql", "mysql", "plsql" }

return {
   {
      "tpope/vim-dadbod",
      cmd = "DB",
   },
   {
      "kristijanhusak/vim-dadbod-completion",
      dependencies = "vim-dadbod",
      ft = sql_ft,
      init = function()
         vim.api.nvim_create_autocmd("FileType", {
            pattern = sql_ft,
            callback = function()
               -- Check if cmp is available instead of using LazyVim
               local has_cmp, cmp = pcall(require, "cmp")
               if has_cmp then
                  -- global sources
                  ---@param source cmp.SourceConfig
                  local sources = vim.tbl_map(function(source)
                     return { name = source.name }
                  end, cmp.get_config().sources)

                  -- add vim-dadbod-completion source
                  table.insert(sources, { name = "vim-dadbod-completion" })

                  -- update sources for the current buffer
                  cmp.setup.buffer({ sources = sources })
               end
            end,
         })
      end,
   },
   {
      "kristijanhusak/vim-dadbod-ui",
      cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
      dependencies = "vim-dadbod",
      keys = {
         { "<leader>D", "<cmd>DBUIToggle<CR>", desc = "Toggle DBUI" },
      },
      init = function()
         local data_path = vim.fn.stdpath("data")

         vim.g.db_ui_auto_execute_table_helpers = 1
         vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
         vim.g.db_ui_show_database_icon = true
         vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
         vim.g.db_ui_use_nerd_fonts = true
         vim.g.db_ui_use_nvim_notify = true

         -- NOTE: The default behavior of auto-execution of queries on save is disabled
         vim.g.db_ui_execute_on_save = false
      end,
   },
   {
      "folke/edgy.nvim",
      optional = true,
      opts = function(_, opts)
         opts.right = opts.right or {}
         table.insert(opts.right, {
            title = "Database",
            ft = "dbui",
            pinned = true,
            width = 0.3,
            open = function()
               vim.cmd("DBUI")
            end,
         })

         opts.bottom = opts.bottom or {}
         table.insert(opts.bottom, {
            title = "DB Query Result",
            ft = "dbout",
         })
      end,
   },
   {
      "saghen/blink.cmp",
      optional = true,
      opts = {
         sources = {
            default = { "dadbod" },
            providers = {
               dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
            },
         },
      },
      dependencies = {
         "kristijanhusak/vim-dadbod-completion",
      },
   },
}
