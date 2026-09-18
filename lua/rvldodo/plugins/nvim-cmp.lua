return {
   "hrsh7th/nvim-cmp",
   event = "InsertEnter",
   dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp-signature-help", -- function signatures with active param
      "hrsh7th/cmp-nvim-lua", -- neovim Lua runtime API
      "hrsh7th/cmp-calc", -- inline math calculations
      {
         "L3MON4D3/LuaSnip",
         version = "v2.*",
         build = "make install_jsregexp",
      },
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
      "saecki/crates.nvim", -- Rust crates source
   },
   config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- Load VSCode-style snippets (friendly-snippets ships rust/rustdoc).
      require("luasnip.loaders.from_vscode").lazy_load()

      -- friendly-snippets registers its Flutter snippets under the `flutter`
      -- language scope (snippets/frameworks/flutter.json), but `.dart` files
      -- have filetype `dart`. Extend so Dart buffers also pull in the Flutter
      -- set (statelessW, statefulW, initS, build, …).
      luasnip.filetype_extend("dart", { "flutter" })

      -- Own Lua snippets live in <config>/snippets/<ft>.lua. NestJS ones are
      -- registered under a `nestjs` pseudo-filetype (same trick as flutter
      -- above) so they stay in one file and can be pulled into any ft.
      -- Eager `load`, not `lazy_load`: this runs on InsertEnter, after the
      -- buffer's FileType already fired, so the lazy variant would miss it.
      luasnip.filetype_extend("typescript", { "nestjs" })
      require("luasnip.loaders.from_lua").load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

      -- Source-name label shown after the kind icon in the completion menu.
      local source_menu = {
         nvim_lsp = "[LSP]",
         nvim_lsp_signature_help = "[Sig]",
         nvim_lua = "[Lua]",
         luasnip = "[Snip]",
         buffer = "[Buf]",
         path = "[Path]",
         calc = "[Calc]",
         crates = "[Crate]",
      }

      cmp.setup({
         completion = {
            completeopt = "menu,menuone,preview,noselect",
         },
         snippet = {
            expand = function(args)
               luasnip.lsp_expand(args.body)
            end,
         },
         window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
         },
         mapping = cmp.mapping.preset.insert({
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-k>"] = cmp.mapping.select_prev_item(),
            ["<C-j>"] = cmp.mapping.select_next_item(),
            -- Tab / S-Tab navigate the menu, jump through snippet placeholders,
            -- and fall back to a literal Tab outside both contexts.
            ["<Tab>"] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_next_item()
               elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
               else
                  fallback()
               end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
               if cmp.visible() then
                  cmp.select_prev_item()
               elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
               else
                  fallback()
               end
            end, { "i", "s" }),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({
               behavior = cmp.ConfirmBehavior.Insert,
               select = true,
            }),
         }),
         sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip", keyword_length = 2 },
            { name = "crates" },
            { name = "nvim_lua", keyword_length = 2 },
            { name = "path" },
            { name = "calc" },
            { name = "buffer", keyword_length = 2 },
         }),
         formatting = {
            fields = { "kind", "abbr", "menu" },
            format = lspkind.cmp_format({
               mode = "symbol_text",
               maxwidth = 50,
               ellipsis_char = "...",
               before = function(entry, item)
                  item.menu = source_menu[entry.source.name] or ("[" .. entry.source.name .. "]")
                  return item
               end,
            }),
         },
      })

      -- Filetype mapping for React
      vim.filetype.add({
         extension = {
            jsx = "javascriptreact",
            tsx = "typescriptreact",
         },
      })
   end,
}
