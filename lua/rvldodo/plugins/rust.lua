return {
   {
      "mrcjkb/rustaceanvim",
      version = "^5",
      ft = { "rust" },
      lazy = false,
      config = function()
         -- Resolve codelldb paths via Mason install dir.
         -- Uses absolute path so it works even before codelldb is installed by mason-tool-installer.
         local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb"
         local codelldb_path = mason_path .. "/extension/adapter/codelldb"
         local liblldb_path = mason_path .. "/extension/lldb/lib/liblldb.dylib"
         -- On Linux use:
         -- local liblldb_path = mason_path .. "/extension/lldb/lib/liblldb.so"
         local cfg = require("rustaceanvim.config")

         vim.g.rustaceanvim = {
            dap = {
               adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
            },
            server = {
               on_attach = function(_, bufnr)
                  -- Hover actions (was rust-tools rt.hover_actions.hover_actions)
                  vim.keymap.set("n", "<C-space>", function()
                     vim.cmd.RustLsp({ "hover", "actions" })
                  end, { buffer = bufnr, desc = "Rust hover actions" })
                  -- Code action groups (was rust-tools rt.code_action_group)
                  vim.keymap.set("n", "<Leader>a", function()
                     vim.cmd.RustLsp("codeAction")
                  end, { buffer = bufnr, desc = "Rust code action group" })
               end,
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
}
