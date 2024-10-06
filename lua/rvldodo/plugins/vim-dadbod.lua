return {
   {
      "tpope/vim-dadbod",
   },
   {
      "kristijanhusak/vim-dadbod-ui",
      config = function()
         vim.g.db_ui_execute_on_save = 0
         vim.g.db_ui_show_database_icon = 1
      end,
   },
   {
      "kristijanhusak/vim-dadbod-completion",
      config = function()
         vim.cmd([[
         autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({sources = {{name = 'vim-dadbod-completion'}}})
         ]])
      end,
   },
}
