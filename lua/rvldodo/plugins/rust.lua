return {
   -- Modern Rust tooling (replaces rust-tools.nvim and rust.vim)
   {
      "mrcjkb/rustaceanvim",
      version = "^5",
      lazy = false,
      ft = { "rust" },
      config = function()
         vim.g.rustaceanvim = {
            -- LSP configuration
            server = {
               on_attach = function(client, bufnr)
                  -- Hover actions
                  vim.keymap.set("n", "K", function()
                     vim.cmd.RustLsp({ "hover", "actions" })
                  end, { buffer = bufnr, desc = "Hover Actions" })

                  -- Code actions
                  vim.keymap.set("n", "<leader>ca", function()
                     vim.cmd.RustLsp("codeAction")
                  end, { buffer = bufnr, desc = "Code Action" })

                  -- Run/Debug runnables
                  vim.keymap.set("n", "<leader>rr", function()
                     vim.cmd.RustLsp("runnables")
                  end, { buffer = bufnr, desc = "Rust Runnables" })
               end,
               default_settings = {
                  ["rust-analyzer"] = {
                     cargo = {
                        allFeatures = true,
                        loadOutDirsFromCheck = true,
                        buildScripts = {
                           enable = true,
                        },
                     },
                     checkOnSave = {
                        enable = true,
                        command = "clippy",
                     },
                     procMacro = {
                        enable = true,
                     },
                     inlayHints = {
                        enable = true,
                     },
                  },
               },
            },
            -- DAP configuration (debugging)
            dap = {
               -- Uncomment if you want debugging support via codelldb
               -- adapter = require('rustaceanvim.config').get_codelldb_adapter(
               --    vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
               --    vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so"
               -- ),
            },
         }
      end,
   },

   -- Cargo.toml dependency hints and management
   {
      "saecki/crates.nvim",
      event = { "BufRead Cargo.toml" },
      config = function()
         require("crates").setup({
            completion = {
               cmp = { enabled = true },
            },
            lsp = {
               enabled = true,
               actions = true,
               completion = true,
               hover = true,
            },
         })
      end,
   },

   -- DAP (Debugger) - Optional but recommended
   {
      "mfussenegger/nvim-dap",
      ft = "rust",
      config = function()
         -- Basic DAP keymaps
         vim.keymap.set("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "Toggle Breakpoint" })
         vim.keymap.set("n", "<leader>dc", "<cmd>DapContinue<CR>", { desc = "Continue" })
         vim.keymap.set("n", "<leader>ds", "<cmd>DapStepOver<CR>", { desc = "Step Over" })
         vim.keymap.set("n", "<leader>di", "<cmd>DapStepInto<CR>", { desc = "Step Into" })
      end,
   },

   -- Show variable values inline while debugging
   {
      "theHamsta/nvim-dap-virtual-text",
      dependencies = { "mfussenegger/nvim-dap" },
      config = function()
         require("nvim-dap-virtual-text").setup({
            enabled = true,
            enabled_commands = true,
            highlight_changed_variables = true,
            highlight_new_as_changed = false,
            show_stop_reason = true,
            commented = false,
         })
      end,
   },
}
