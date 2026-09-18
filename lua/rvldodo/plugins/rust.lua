return {
   {
      "mrcjkb/rustaceanvim",
      version = "^5",
      ft = { "rust" },
      config = function()
         -- Resolve codelldb paths via Mason install dir.
         -- Uses absolute path so it works even before codelldb is installed by mason-tool-installer.
         local mason_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb"
         local codelldb_path = mason_path .. "/extension/adapter/codelldb"
         local this_os = vim.uv.os_uname().sysname
         local liblldb_ext = this_os == "Linux" and ".so" or ".dylib"
         local liblldb_path = mason_path .. "/extension/lldb/lib/liblldb" .. liblldb_ext
         local cfg = require("rustaceanvim.config")

         -- Advertise nvim-cmp's expanded capabilities so rust-analyzer
         -- emits snippet/resolve-supporting completion items.
         local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
         local capabilities = ok_cmp and cmp_nvim_lsp.default_capabilities()
            or vim.lsp.protocol.make_client_capabilities()

         vim.g.rustaceanvim = {
            dap = {
               adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
            },
            server = {
               capabilities = capabilities,
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
               default_settings = {
                  ["rust-analyzer"] = {
                     cargo = {
                        allFeatures = false, -- 🔥 IMPORTANT (true = slower)
                     },
                     checkOnSave = true,
                     check = {
                        command = "clippy",
                     },
                     procMacro = {
                        enable = true,
                     },
                     completion = {
                        -- Show every callable with parentheses + snippet placeholders
                        -- so <Tab> jumps through arguments.
                        callable = { snippets = "fill_arguments" },
                        -- Enable postfix snippets: `foo.dbg`, `foo.let`, `foo.match`,
                        -- `foo.while`, `foo.ref`, `foo.refm`, `foo.box`, etc.
                        postfix = { enable = true },
                        -- Suggest auto-imports for unimported items.
                        autoimport = { enable = true },
                        autoself = { enable = true },
                        -- Show full function signatures (params + return) in the menu.
                        fullFunctionSignatures = { enable = true },
                        -- Show private items from the current crate.
                        privateEditable = { enable = true },
                        -- Limit how many results are returned (default 200 — leave it large).
                        limit = 500,
                        -- Built-in custom snippets that rust-analyzer ships:
                        -- typing `arc` suggests `Arc::new(${receiver})`, etc.
                        snippets = {
                           custom = {
                              ["Arc::new"] = {
                                 postfix = "arc",
                                 body = "Arc::new(${receiver})",
                                 requires = "std::sync::Arc",
                                 description = "Put the expression into an `Arc`",
                                 scope = "expr",
                              },
                              ["Rc::new"] = {
                                 postfix = "rc",
                                 body = "Rc::new(${receiver})",
                                 requires = "std::rc::Rc",
                                 description = "Put the expression into an `Rc`",
                                 scope = "expr",
                              },
                              ["Box::pin"] = {
                                 postfix = "pinbox",
                                 body = "Box::pin(${receiver})",
                                 requires = "std::boxed::Box",
                                 description = "Put the expression into a pinned `Box`",
                                 scope = "expr",
                              },
                              ["Ok"] = {
                                 postfix = "ok",
                                 body = "Ok(${receiver})",
                                 description = "Wrap the expression in a `Result::Ok`",
                                 scope = "expr",
                              },
                              ["Err"] = {
                                 postfix = "err",
                                 body = "Err(${receiver})",
                                 description = "Wrap the expression in a `Result::Err`",
                                 scope = "expr",
                              },
                              ["Some"] = {
                                 postfix = "some",
                                 body = "Some(${receiver})",
                                 description = "Wrap the expression in an `Option::Some`",
                                 scope = "expr",
                              },
                           },
                        },
                     },
                     -- Inlay hints help discover types/params while typing.
                     inlayHints = {
                        bindingModeHints = { enable = false },
                        chainingHints = { enable = true },
                        closingBraceHints = { enable = true, minLines = 25 },
                        closureReturnTypeHints = { enable = "never" },
                        lifetimeElisionHints = { enable = "never" },
                        parameterHints = { enable = true },
                        reborrowHints = { enable = "never" },
                        renderColons = true,
                        typeHints = {
                           enable = true,
                           hideClosureInitialization = false,
                           hideNamedConstructor = false,
                        },
                     },
                     -- Don't hide diagnostics from disabled features.
                     diagnostics = {
                        enable = true,
                        experimental = { enable = true },
                     },
                  },
               },
            },
         }
      end,
   },
   {
      "saecki/crates.nvim",
      ft = { "toml" },
      opts = {
         completion = {
            cmp = {
               enabled = true,
            },
         },
      },
   },
   {
      "theHamsta/nvim-dap-virtual-text",
      lazy = false,
      opts = {},
   },
}
