return {
   "stevearc/conform.nvim",
   event = { "BufReadPre", "BufNewFile" },
   config = function()
      local conform = require("conform")

      -- JS/TS, all decided per project by core/typescript.lua:
      --   1. oxlint --fix   (only when the project has .oxlintrc.json)
      --   2. biome | prettier, whichever config the project ships
      --   3. eslint fix-all (only when the eslint LSP is attached, i.e. the
      --      project has an eslint config; `name` keeps ts_ls out of it)
      -- Lint fixes bracket the formatter so the file ends up exactly as
      -- `npm run lint -- --fix && npm run format` would leave it.
      local function js(bufnr)
         local ts = require("rvldodo.core.typescript")
         local steps = {}
         if ts.linter(bufnr) == "oxlint" then
            table.insert(steps, "oxlint")
         end
         table.insert(steps, ts.formatter(bufnr))
         steps.lsp_format = "last"
         steps.name = "eslint"
         return steps
      end

      conform.setup({
         -- Per-filetype `lsp_format` above only applies when the caller does
         -- not pass one, so the default lives here instead of in each call.
         default_format_opts = {
            lsp_format = "fallback",
         },
         formatters_by_ft = {
            javascript = js,
            typescript = js,
            javascriptreact = js,
            typescriptreact = js,
            svelte = { "prettier" },
            css = { "prettier" },
            html = { "prettier" },
            json = { "biome" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            graphql = { "prettier" },
            liquid = { "prettier" },
            lua = { "stylua" },
            python = { "ruff_organize_imports", "ruff_format" },
            go = { "golines" },
            proto = { "protolint" },
            rust = { "rustfmt", lsp_format = "fallback" },
            kotlin = { "ktlint" },
            c = { "clang_format" },
            cpp = { "clang_format" },
            objc = { "clang_format" },
            objcpp = { "clang_format" },
            cuda = { "clang_format" },
            cs = { "csharpier", lsp_format = "fallback" },
            cmake = { lsp_format = "fallback" },
         },
         formatters = {
            -- conform's builtin runs the project's node_modules/.bin/oxlint
            -- on a temp copy next to the file; pin cwd to the config's dir so
            -- oxlint resolves .oxlintrc.json regardless of nvim's cwd.
            oxlint = {
               cwd = require("conform.util").root_file({ ".oxlintrc.json" }),
            },
            -- A project's own .clang-format always wins; without one, clang-format
            -- would fall back to LLVM style (2-space, 80 cols). Google style is a
            -- closer match to how the rest of this config formats.
            clang_format = {
               prepend_args = { "--style=file", "--fallback-style=Google" },
            },
         },
         format_on_save = function(bufnr)
            -- *.ipynb buffers (via jupytext.nvim) hold `!shell` / `%magic`
            -- lines ruff can't parse, and reformatting course notebooks on
            -- every save makes noisy diffs against upstream. Skip them.
            if vim.api.nvim_buf_get_name(bufnr):match("%.ipynb$") then
               return nil
            end
            return {
               async = false,
               timeout_ms = 1000,
            }
         end,
      })

      vim.keymap.set({ "n", "v" }, "<leader>mp", function()
         conform.format({
            async = false,
            timeout_ms = 1000,
         })
      end, { desc = "Format file or range (in visual mode)" })
   end,
}
