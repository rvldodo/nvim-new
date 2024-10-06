return {
   {
      "uarun/vim-protobuf",
      ft = { "proto" },
   },
   {
      "dense-analysis/ale",
      ft = { "proto" },
      config = function()
         vim.g.ale_linters = {
            proto = { "buf-lint" },
         }
         vim.g.ale_fix_on_save = 1
         vim.g.ale_lint_on_text_changed = "never"
         vim.g.ale_linters_explicit = 1
      end,
   },
   {
      "jose-elias-alvarez/null-ls.nvim",
      event = { "BufReadPre", "BufNewFile" },
      config = function(_)
         local null_ls = require("null-ls")
         local opts = {
            sources = {},
         }
         vim.list_extend(opts.sources, {
            -- Formatting with protolint
            null_ls.builtins.formatting.protolint,

            -- OR formatting with clang-format
            null_ls.builtins.formatting.clang_format.with({
               filetypes = { "proto" },
            }),
         })
         vim.keymap.set(
            "n",
            "<leader>pf",
            ":lua vim.lsp.buf.format({async = true})<CR>",
            { noremap = true, silent = true }
         )
      end,
   },
}
