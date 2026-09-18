return {
   {
      "akinsho/flutter-tools.nvim",
      ft = { "dart" },
      dependencies = {
         "nvim-lua/plenary.nvim",
         "stevearc/dressing.nvim", -- nicer UI for FlutterOutlineToggle / device picker
      },
      config = function()
         -- Advertise nvim-cmp's expanded capabilities so dartls
         -- emits snippet/resolve-supporting completion items.
         local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
         local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities()
            or vim.lsp.protocol.make_client_capabilities()

         require("flutter-tools").setup({
            -- `flutter` is on PATH (homebrew) at /opt/homebrew/bin/flutter,
            -- so flutter-tools auto-resolves the bundled Dart SDK — no
            -- flutter_lookup_cmd needed (that's only for version managers
            -- like fvm/asdf).
            lsp = {
               capabilities = capabilities,
               settings = {
                  showTodos = true,
                  completeFunctionCalls = true, -- fill argument placeholders
                  renameFilesWithClasses = "prompt",
                  enableSnippets = true,
                  updateImportsOnRename = true,
               },
               on_attach = function(_, bufnr)
                  -- Native inline color swatches (Neovim 0.12+) — replaces the
                  -- deprecated flutter-tools `lsp.color` option.
                  if vim.lsp.document_color and vim.lsp.document_color.enable then
                     vim.lsp.document_color.enable(true, bufnr)
                  end

                  local opts = { buffer = bufnr, silent = true }

                  opts.desc = "Flutter run"
                  vim.keymap.set("n", "<leader>Fr", "<cmd>FlutterRun<CR>", opts)

                  opts.desc = "Flutter hot reload"
                  vim.keymap.set("n", "<leader>Fh", "<cmd>FlutterReload<CR>", opts)

                  opts.desc = "Flutter hot restart"
                  vim.keymap.set("n", "<leader>FR", "<cmd>FlutterRestart<CR>", opts)

                  opts.desc = "Flutter quit"
                  vim.keymap.set("n", "<leader>Fq", "<cmd>FlutterQuit<CR>", opts)

                  opts.desc = "Flutter pick device"
                  vim.keymap.set("n", "<leader>Fd", "<cmd>FlutterDevices<CR>", opts)

                  opts.desc = "Flutter open DevTools"
                  vim.keymap.set("n", "<leader>FD", "<cmd>FlutterDevTools<CR>", opts)

                  opts.desc = "Flutter outline toggle"
                  vim.keymap.set("n", "<leader>Fo", "<cmd>FlutterOutlineToggle<CR>", opts)
               end,
            },

            -- Visual widget guides (the vertical lines connecting nested widgets).
            widget_guides = { enabled = true },

            -- Render the DevTools URL/log in a split rather than swallowing it.
            dev_log = { enabled = true, open_cmd = "tabedit" },

            -- Use nvim-dap for debugging; register the Dart/Flutter adapters
            -- and a default launch configuration so <leader>dc just works.
            debugger = {
               enabled = true,
               run_via_dap = true,
               register_configurations = function(_)
                  require("dap.ext.vscode").load_launchjs()
               end,
            },
         })
      end,
   },
}
