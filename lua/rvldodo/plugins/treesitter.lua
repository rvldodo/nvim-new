return {
   "nvim-treesitter/nvim-treesitter",
   branch = "master", -- the `main` branch is a rewrite; keeps `nvim-treesitter.configs` API
   event = { "BufReadPre", "BufNewFile" },
   build = ":TSUpdate",
   dependencies = {
      "windwp/nvim-ts-autotag",
   },
   config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter.configs")

      -- configure treesitter
      treesitter.setup({ -- enable syntax highlighting
         highlight = {
            enable = true,
         },
         -- enable indentation
         indent = { enable = true },
         -- enable autotagging (w/ nvim-ts-autotag plugin)
         autotag = {
            enable = true,
         },
         -- ensure these language parsers are installed
         ensure_installed = {
            "json",
            "javascript",
            "typescript",
            "tsx",
            "yaml",
            "html",
            "css",
            "prisma",
            "markdown",
            "markdown_inline",
            "svelte",
            "graphql",
            "bash",
            "lua",
            "vim",
            "dockerfile",
            "gitignore",
            "query",
            "vimdoc",
            "c",
            "go",
            -- "proto",
         },
         incremental_selection = {
            enable = true,
            keymaps = {
               init_selection = "<C-space>",
               node_incremental = "<C-space>",
               scope_incremental = false,
               node_decremental = "<bs>",
            },
         },
      })

      -- ───────────────────────────────────────────────────────────────────
      -- Neovim 0.12 compat patch for nvim-treesitter (master branch).
      -- In 0.12+, query directive captures arrive as a list of nodes
      -- (TSNode[]) rather than a single TSNode. The plugin's
      -- `set-lang-from-info-string!` and `set-lang-from-mimetype!` directives
      -- call `get_node_text(node)` directly on what is now a table, which
      -- crashes the treesitter highlighter on every markdown / HTML buffer
      -- and breaks render-markdown.nvim. Re-register them with the fix.
      -- Safe to remove once nvim-treesitter `main` branch is adopted.
      -- ───────────────────────────────────────────────────────────────────
      do
         local q = vim.treesitter.query
         local opts = { force = true, all = false }

         local non_filetype_aliases = {
            ex = "elixir",
            pl = "perl",
            sh = "bash",
            uxn = "uxntal",
            ts = "typescript",
         }

         local function lang_from_info_string(alias)
            local m = vim.filetype.match({ filename = "a." .. alias })
            return m or non_filetype_aliases[alias] or alias
         end

         q.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
            local node = match[pred[2]]
            if type(node) == "table" then
               node = node[1]
            end
            if not node then
               return
            end
            local alias = vim.treesitter.get_node_text(node, bufnr):lower()
            metadata["injection.language"] = lang_from_info_string(alias)
         end, opts)

         local html_script_type_languages = {
            ["importmap"] = "json",
            ["module"] = "javascript",
            ["application/ecmascript"] = "javascript",
            ["text/ecmascript"] = "javascript",
         }

         q.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
            local node = match[pred[2]]
            if type(node) == "table" then
               node = node[1]
            end
            if not node then
               return
            end
            local val = vim.treesitter.get_node_text(node, bufnr)
            local configured = html_script_type_languages[val]
            if configured then
               metadata["injection.language"] = configured
            else
               local parts = vim.split(val, "/", {})
               metadata["injection.language"] = parts[#parts]
            end
         end, opts)
      end
   end,
}
