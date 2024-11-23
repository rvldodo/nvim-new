return {
   {
      "rust-lang/rust.vim",
      ft = "rust",
      init = function()
         vim.g.rustfmt_autosave = 1
      end,
   },
   {
      "mrcjkb/rustaceanvim",
      version = "^4",
      ft = { "rust" },
      dependencies = "neovim/nvim-lspconfig",
      config = function()
         local cmp_nvim_lsp = require("cmp_nvim_lsp")
         local on_attach = require("plugins.configs.lspconfig").on_attach
         local capabilities = cmp_nvim_lsp.default_capabilities()
         vim.g.rustaceanvim = {
            server = {
               on_attach = on_attach,
               capabilities = capabilities,
            },
         }
      end,
   },
   {
      "saecki/crates.nvim",
      ft = { "toml" },
      config = function(_, opts)
         local crates = require("crates")
         crates.setup(opts)
         require("cmp").setup.buffer({
            sources = { { name = "crates" } },
         })
         crates.show()
         require("core.utils").load_mappings("crates")
      end,
   },
   {
      "theHamsta/nvim-dap-virtual-text",
      lazy = false,
      config = function(_, opts)
         require("nvim-dap-virtual-text").setup()
      end,
   },
}
