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
      version = "^5",
      ft = { "rust" },
      lazy = false,
      config = function()
         local mason_registry = require("mason-registry")
         local codelldb = mason_registry.get_package("codelldb")
         local extension_path = codelldb:get_install_path() .. "/extension/"
         local codelldb_path = extension_path .. "adapter/codelldb"
         local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
         -- If you are on Linux, replace the line above with the line below:
         -- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
         local cfg = require("rustaceanvim.config")

         vim.g.rustaceanvim = {
            dap = {
               adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
            },
         }
      end,
   },
   {
      "saecki/crates.nvim",
      ft = { "toml" },
      config = function()
         require("crates").setup({
            completion = {
               cmp = {
                  enabled = true,
               },
            },
         })
         require("cmp").setup.buffer({
            sources = { { name = "crates" } },
         })
      end,
   },
   {
      "theHamsta/nvim-dap-virtual-text",
      lazy = false,
      config = function(_, opts)
         require("nvim-dap-virtual-text").setup()
      end,
   },
   {
      "simrat39/rust-tools.nvim",
      ft = "rust",
      dependencies = "neovim/nvim-lspconfig",
      opts = function()
         local cmp_nvim_lsp = require("cmp_nvim_lsp")
         -- local on_attach = require("plugins.configs.lspconfig").on_attach

         local rt = require("rust-tools")

         vim.g.rustaceanvim = {
            server = {
               on_attach = function(_, bufnr)
                  -- Hover actions
                  vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
                  -- Code action groups
                  vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
               end,
            },
         }
      end,
      config = function(_, opts)
         require("rust-tools").setup(opts)
      end,
   },
}
