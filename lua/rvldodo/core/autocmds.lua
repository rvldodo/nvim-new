vim.api.nvim_create_augroup("jdtls_lsp", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
   group = "jdtls_lsp",
   pattern = "java",
   callback = function()
      require("rvldodo.core.jdtls").setup_jdtls()
   end,
})
