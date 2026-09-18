return {
   "neovim/nvim-lspconfig",
   version = "^1.0", -- pin to v1.x; v2 dropped lspconfig.X.setup() in favor of vim.lsp.config
   event = { "BufReadPre", "BufNewFile" },
   dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "antosha417/nvim-lsp-file-operations", config = true },
      { "folke/neodev.nvim", opts = {} },
      -- Decompilation-aware go-to-definition for omnisharp (see the handler below).
      "Hoffs/omnisharp-extended-lsp.nvim",
   },
   config = function()
      -- import lspconfig plugin
      local lspconfig = require("lspconfig")

      -- import mason_lspconfig plugin
      local mason_lspconfig = require("mason-lspconfig")

      -- import cmp-nvim-lsp plugin
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      local keymap = vim.keymap -- for conciseness

      -- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      -- ADD THE BORDER CONFIGURATION RIGHT HERE
      -- Make floating windows have a border
      local _border = "rounded"

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
         border = _border,
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signatureHelp, {
         border = _border,
      })

      vim.diagnostic.config({
         float = { border = _border },
         -- other diagnostic config can stay here
      })
      -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

      vim.api.nvim_create_autocmd("LspAttach", {
         group = vim.api.nvim_create_augroup("UserLspConfig", {}),
         callback = function(ev)
            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf, silent = true }

            -- set keybinds
            opts.desc = "Show LSP references"
            keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

            opts.desc = "Go to declaration"
            keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

            opts.desc = "Show LSP definitions"
            keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

            opts.desc = "Show LSP implementations"
            keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

            opts.desc = "Show LSP type definitions"
            keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

            opts.desc = "See available code actions"
            keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

            opts.desc = "Smart rename"
            keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

            opts.desc = "Show buffer diagnostics"
            keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

            opts.desc = "Show line diagnostics"
            keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

            opts.desc = "Go to previous diagnostic"
            keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

            opts.desc = "Go to next diagnostic"
            keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

            opts.desc = "Show documentation for what is under cursor"
            keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

            opts.desc = "Restart LSP"
            keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
         end,
      })

      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = cmp_nvim_lsp.default_capabilities()

      -- Change the Diagnostic symbols in the sign column (gutter)
      -- (not in youtube nvim video)
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
         local hl = "DiagnosticSign" .. type
         vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- oxlint's language server is `oxlint --lsp`. mason-lspconfig v1 has no
      -- entry for it, so it is configured here rather than in the handlers
      -- below. The project's own oxlint is preferred (its version matches
      -- the project's .oxlintrc.json schema); mason's is the fallback.
      lspconfig.oxlint.setup({
         capabilities = capabilities,
         on_new_config = function(config, root_dir)
            local bin = require("rvldodo.core.typescript").local_bin("oxlint", root_dir)
               or vim.fn.stdpath("data") .. "/mason/bin/oxlint"
            config.cmd = { bin, "--lsp" }
         end,
         init_options = {
            settings = {
               run = "onType",
               -- Rules like typescript/no-floating-promises (in Nest's default
               -- .oxlintrc.json) need type info from the project's
               -- oxlint-tsgolint. Best effort: with tsgolint missing or
               -- broken (as in a fresh `nest new` today) the server just
               -- runs the syntactic rules.
               typeAware = true,
            },
         },
         on_attach = function(_, bufnr)
            vim.keymap.set("n", "<leader>ce", "<cmd>OxcFixAll<CR>", {
               buffer = bufnr,
               silent = true,
               desc = "oxlint: fix all in buffer",
            })
         end,
      })

      mason_lspconfig.setup_handlers({
         -- default handler for installed servers
         function(server_name)
            lspconfig[server_name].setup({
               capabilities = capabilities,
            })
         end,
         ["svelte"] = function()
            -- configure svelte server
            lspconfig["svelte"].setup({
               capabilities = capabilities,
               on_attach = function(client, bufnr)
                  vim.api.nvim_create_autocmd("BufWritePost", {
                     pattern = { "*.js", "*.ts" },
                     callback = function(ctx)
                        -- Here use ctx.match instead of ctx.file
                        client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
                     end,
                  })
               end,
            })
         end,
         ["graphql"] = function()
            -- configure graphql language server
            lspconfig["graphql"].setup({
               capabilities = capabilities,
               filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
            })
         end,
         ["emmet_ls"] = function()
            -- configure emmet language server
            lspconfig["emmet_ls"].setup({
               capabilities = capabilities,
               filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
            })
         end,
         ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
               capabilities = capabilities,

               settings = {
                  Lua = {
                     diagnostics = {
                        globals = { "vim" },
                     },
                     workspace = {
                        checkThirdParty = false,
                     },
                     telemetry = {
                        enable = false,
                     },
                  },
               },
            })
         end,
         ["gopls"] = function()
            lspconfig.gopls.setup({
               capabilities = capabilities,

               settings = {
                  gopls = {
                     analyses = {
                        unusedparams = true,
                        unusedwrite = true,
                     },
                     staticcheck = true,
                     gofumpt = true,

                     -- performance
                     usePlaceholders = false,
                     completeUnimported = true,
                  },
               },
            })
         end,
         ["html"] = function()
            lspconfig["html"].setup({
               capabilities = capabilities,
               filetypes = { "html", "templ" },
            })
         end,
         -- ["proto"] = function()
         --    lspconfig["proto"].setup({
         --       cmd = { "bufls", "serve" },
         --       filetypes = { "proto" },
         --       root_dir = lspconfig.util.root_pattern("buf.yaml", ".git"),
         --    })
         ["ts_ls"] = function()
            -- Run one of tsserver's workspace commands on the current file.
            -- These are code actions in the LSP sense but tsserver only
            -- offers them as commands, so a keymap is the only way in.
            local function ts_command(bufnr, command)
               local params = {
                  command = command,
                  arguments = { vim.api.nvim_buf_get_name(bufnr) },
               }
               vim.lsp.buf_request(bufnr, "workspace/executeCommand", params)
            end

            -- Same thing for the `source.*` code-action kinds tsserver does
            -- expose. `apply = true` picks the single matching action.
            local function ts_source_action(kind)
               vim.lsp.buf.code_action({
                  context = { only = { kind }, diagnostics = {} },
                  apply = true,
               })
            end

            lspconfig.ts_ls.setup({
               capabilities = capabilities,

               settings = {
                  typescript = {
                     inlayHints = {
                        includeInlayParameterNameHints = "none",
                        includeInlayVariableTypeHints = false,
                     },
                  },
               },

               init_options = {
                  preferences = {
                     -- Nest (and most Node backends) import with relative
                     -- paths; without this tsserver sometimes picks
                     -- `src/users/...` which only resolves via tsconfig paths.
                     importModuleSpecifierPreference = "relative",
                     -- Nest's own files use single quotes; match them when
                     -- auto-import inserts a new statement.
                     quotePreference = "single",
                  },
               },

               on_attach = function(client, bufnr)
                  -- Formatting is conform's job (biome / prettier).
                  client.server_capabilities.documentFormattingProvider = false

                  local map = function(lhs, rhs, desc)
                     vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                  end
                  map("<leader>co", function()
                     ts_command(bufnr, "_typescript.organizeImports")
                  end, "TS: organize imports")
                  map("<leader>cm", function()
                     ts_source_action("source.addMissingImports.ts")
                  end, "TS: add missing imports")
                  map("<leader>cu", function()
                     ts_source_action("source.removeUnused.ts")
                  end, "TS: remove unused")
               end,

               filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
            })
         end,
         -- Two linters, because `nest new` changed its mind: Nest ≤ 11
         -- projects ship eslint, Nest 12+ ship oxlint. Each server only
         -- attaches when its config file exists, so a project gets exactly
         -- one of them. Fix-on-save for both is wired in formatting.lua.
         --
         -- vscode-eslint-language-server. Diagnostics + `fix this` / `disable
         -- rule` code actions; fix-all on save happens through conform
         -- (formatting.lua runs the eslint client's formatter last).
         -- root_dir is the nearest eslint config, so it never attaches to a
         -- project that has no eslint and won't fight biome's own linting.
         ["eslint"] = function()
            lspconfig.eslint.setup({
               capabilities = capabilities,
               settings = {
                  -- Monorepo: resolve config + plugins relative to the package
                  -- that owns the file, not the workspace root.
                  workingDirectories = { mode = "auto" },
               },
               on_attach = function(_, bufnr)
                  vim.keymap.set("n", "<leader>ce", "<cmd>EslintFixAll<CR>", {
                     buffer = bufnr,
                     silent = true,
                     desc = "ESLint: fix all in buffer",
                  })
               end,
            })
         end,
         -- rust_analyzer is owned by rustaceanvim (see plugins/rust.lua).
         -- Returning a no-op handler prevents mason-lspconfig from running
         -- the default handler and double-attaching the LSP.
         ["rust_analyzer"] = function() end,
         ["biome"] = function()
            lspconfig["biome"].setup({
               capabilities = capabilities,
            })
         end,
         ["kotlin_language_server"] = function()
            lspconfig.kotlin_language_server.setup({
               capabilities = capabilities,

               -- Root markers tuned for Kotlin Multiplatform / Gradle KTS
               -- projects so the server picks up shared + platform modules.
               root_dir = lspconfig.util.root_pattern(
                  "settings.gradle",
                  "settings.gradle.kts",
                  "build.gradle",
                  "build.gradle.kts",
                  "pom.xml",
                  ".git"
               ),

               settings = {
                  kotlin = {
                     -- Surface compiler warnings/errors as you type.
                     compiler = {
                        jvm = { target = "17" },
                     },
                  },
               },
            })
         end,
         ["clangd"] = function()
            -- clangd advertises utf-16 only; nvim-cmp's capabilities claim utf-8
            -- first, which makes clangd log an offset-encoding warning on attach.
            local clangd_capabilities = vim.tbl_deep_extend("force", {}, capabilities)
            clangd_capabilities.offsetEncoding = { "utf-16" }

            lspconfig.clangd.setup({
               capabilities = clangd_capabilities,
               cmd = {
                  "clangd",
                  "--background-index",
                  "--clang-tidy",
                  "--header-insertion=iwyu",
                  "--completion-style=detailed",
                  "--function-arg-placeholders",
                  -- Without this, clangd resolves `gcc`/`g++` flags it doesn't
                  -- understand as errors on plain Makefile projects.
                  "--query-driver=/usr/bin/*,/opt/homebrew/bin/*",
                  "--fallback-style=Google",
               },
               init_options = {
                  usePlaceholders = true,
                  completeUnimported = true,
                  clangdFileStatus = true,
               },
               -- compile_commands.json is what makes clangd accurate. Look for it
               -- where CMake and Bear put it before falling back to the git root.
               root_dir = function(fname)
                  return lspconfig.util.root_pattern(
                     ".clangd",
                     "compile_commands.json",
                     "compile_flags.txt",
                     "build/compile_commands.json",
                     "CMakeLists.txt",
                     "Makefile",
                     "configure.ac",
                     ".git"
                  )(fname) or vim.fs.dirname(fname)
               end,
               on_attach = function(_, bufnr)
                  vim.keymap.set(
                     "n",
                     "<leader>ch",
                     "<cmd>ClangdSwitchSourceHeader<CR>",
                     { buffer = bufnr, desc = "C/C++: switch source ↔ header" }
                  )
               end,
            })
         end,
         ["neocmake"] = function()
            lspconfig.neocmake.setup({
               capabilities = capabilities,
               -- lspconfig still ships `--stdio`; neocmakelsp 0.10 turned the
               -- transports into subcommands and exits on the old flag.
               cmd = { "neocmakelsp", "stdio" },
               root_dir = function(fname)
                  return lspconfig.util.root_pattern("CMakeLists.txt", ".git")(fname) or vim.fs.dirname(fname)
               end,
               init_options = {
                  format = { enable = true },
                  lint = { enable = true },
                  scan_cmake_in_package = true,
               },
            })
         end,
         -- Mason's omnisharp is a launcher script that execs `dotnet`, so with
         -- no .NET SDK on PATH every .cs buffer would raise "dotnet: not found"
         -- on attach. Skip setup instead of spamming the error.
         -- Install the SDK (`brew install --cask dotnet-sdk`) to enable C# LSP.
         ["omnisharp"] = function()
            if vim.fn.executable("dotnet") ~= 1 then
               return
            end

            lspconfig.omnisharp.setup({
               capabilities = capabilities,
               -- Default omnisharp symbols are mangled ("Foo.Bar.Baz" as one
               -- blob); these two make the outline and Telescope pickers usable.
               enable_roslyn_analyzers = true,
               organize_imports_on_format = true,
               enable_import_completion = true,
               -- Treat every project in the tree as one workspace so go-to-def
               -- crosses project boundaries in a multi-project solution.
               enable_ms_build_load_projects_on_demand = false,
               handlers = {
                  ["textDocument/definition"] = function(...)
                     -- Lets you jump into decompiled framework/NuGet sources
                     -- instead of landing on "no definition found".
                     return require("omnisharp_extended").handler(...)
                  end,
               },
               root_dir = lspconfig.util.root_pattern("*.sln", "*.slnx", "*.csproj", "omnisharp.json", ".git"),
               on_attach = function(_, bufnr)
                  -- The global `gd` goes through Telescope, which bypasses the
                  -- handler above. Use omnisharp-extended's Telescope entry point
                  -- so decompiled sources still show up in the picker.
                  vim.keymap.set("n", "gd", function()
                     require("omnisharp_extended").telescope_lsp_definition()
                  end, { buffer = bufnr, desc = "C#: go to definition (decompiled)" })
               end,
            })
         end,
         ["pyright"] = function()
            local py = require("rvldodo.core.python")

            lspconfig.pyright.setup({
               capabilities = capabilities,

               -- Without an explicit pythonPath, pyright falls back to the
               -- first `python3` on PATH and reports every project dependency
               -- as a missing import. Point it at the project's venv instead.
               before_init = function(_, config)
                  config.settings.python.pythonPath = py.interpreter()
               end,

               root_dir = function(fname)
                  return lspconfig.util.root_pattern(
                     "pyproject.toml",
                     "requirements.txt",
                     "setup.py",
                     "setup.cfg",
                     "manage.py", -- django
                     ".git"
                  )(fname) or vim.fn.getcwd()
               end,

               settings = {
                  python = {
                     analysis = {
                        typeCheckingMode = "basic", -- 🔥 faster than strict
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "openFilesOnly", -- 🔥 huge performance boost
                     },
                  },
               },
            })
         end,
         -- Ruff handles linting + quick-fix code actions. Formatting stays with
         -- conform (ruff_format), and hover is disabled so pyright is the single
         -- source of hover docs rather than both servers answering.
         ["ruff"] = function()
            lspconfig.ruff.setup({
               capabilities = capabilities,
               on_attach = function(client)
                  client.server_capabilities.hoverProvider = false
               end,
            })
         end,
      })
   end,
}
