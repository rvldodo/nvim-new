return {
   "folke/snacks.nvim",
   priority = 1000,
   lazy = false,
   ---@type snacks.Config
   opts = {
      bigfile = { enabled = true },
      dashboard = {
         enabled = true,
         sections = {
            { section = "header" },
            { section = "keys", gap = 1, padding = 1 },
            { section = "startup" },
            {
               section = "terminal",
               cmd = "ascii-image-converter ~/.config/nvim/image/joker.png -C -c",
               random = 10,
               pane = 2,
               indent = 4,
               height = 30,
            },
         },
      },
      notifier = {
         enabled = true,
         custom_notifier = function()
            ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
            local progress = vim.defaulttable()

            vim.api.nvim_create_autocmd("LspProgress", {
               ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
               callback = function(ev)
                  local client = vim.lsp.get_client_by_id(ev.data.client_id)
                  local value = ev.data.params.value
                  if not client or type(value) ~= "table" then
                     return
                  end
                  local p = progress[client.id]

                  for i = 1, #p + 1 do
                     if i == #p + 1 or p[i].token == ev.data.params.token then
                        p[i] = {
                           token = ev.data.params.token,
                           msg = ("[%3d%%] %s%s"):format(
                              value.kind == "end" and 100 or value.percentage or 100,
                              value.title or "",
                              value.message and (" **%s**"):format(value.message) or ""
                           ),
                           done = value.kind == "end",
                        }
                        break
                     end
                  end

                  local msg = {} ---@type string[]
                  progress[client.id] = vim.tbl_filter(function(v)
                     return table.insert(msg, v.msg) or not v.done
                  end, p)

                  local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                  vim.notify(table.concat(msg, "\n"), "info", {
                     id = "lsp_progress",
                     title = client.name,
                     opts = function(notif)
                        notif.icon = #progress[client.id] == 0 and " "
                           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                     end,
                  })
               end,
            })
         end,
      },
      win = {
         bo = {
            filetype = "snacks_terminal",
         },
         wo = {},
         keys = {
            q = "hide",
            gf = function(self)
               local f = vim.fn.findfile(vim.fn.expand("<cfile>"), "**")
               if f == "" then
                  Snacks.notify.warn("No file under cursor")
               else
                  self:hide()
                  vim.schedule(function()
                     vim.cmd("e " .. f)
                  end)
               end
            end,
            term_normal = {
               "<esc>",
               function(self)
                  self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
                  if self.esc_timer:is_active() then
                     self.esc_timer:stop()
                     vim.cmd("stopinsert")
                  else
                     self.esc_timer:start(200, 0, function() end)
                     return "<esc>"
                  end
               end,
               mode = "t",
               expr = true,
               desc = "Double escape to normal mode",
            },
         },
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
         notification = {
            border = "rounded",
            zindex = 100,
            ft = "markdown",
            wo = {
               winblend = 5,
               wrap = false,
               conceallevel = 2,
               colorcolumn = "",
            },
            bo = { filetype = "snacks_notif" },
            history = {
               border = "rounded",
               zindex = 100,
               width = 0.6,
               height = 0.6,
               minimal = false,
               title = " Notification History ",
               title_pos = "center",
               ft = "markdown",
               bo = { filetype = "snacks_notif_history" },
               wo = { winhighlight = "Normal:SnacksNotifierHistory" },
               keys = { q = "close" },
            },
         },
      },
   },
   keys = {
      {
         "<leader>.",
         function()
            Snacks.scratch()
         end,
         desc = "Toggle Scratch Buffer",
      },
      {
         "<leader>S",
         function()
            Snacks.scratch.select()
         end,
         desc = "Select Scratch Buffer",
      },
      {
         "<leader>n",
         function()
            Snacks.notifier.show_history()
         end,
         desc = "Notification History",
      },
      {
         "<leader>bd",
         function()
            Snacks.bufdelete()
         end,
         desc = "Delete Buffer",
      },
      {
         "<leader>cR",
         function()
            Snacks.rename.rename_file()
         end,
         desc = "Rename File",
      },
      {
         "<leader>gB",
         function()
            Snacks.gitbrowse()
         end,
         desc = "Git Browse",
      },
      {
         "<leader>gb",
         function()
            Snacks.git.blame_line()
         end,
         desc = "Git Blame Line",
      },
      {
         "<leader>gf",
         function()
            Snacks.lazygit.log_file()
         end,
         desc = "Lazygit Current File History",
      },
      {
         "<leader>lg",
         function()
            Snacks.lazygit()
         end,
         desc = "Lazygit",
      },
      {
         "<leader>gl",
         function()
            Snacks.lazygit.log()
         end,
         desc = "Lazygit Log (cwd)",
      },
      {
         "<leader>un",
         function()
            Snacks.notifier.hide()
         end,
         desc = "Dismiss All Notifications",
      },
      {
         "<C-t>",
         function()
            Snacks.terminal()
         end,
         desc = "Toggle Terminal",
      },
      {
         "<leader>st",
         function()
            Snacks.terminal({ split = "horizontal" })
         end,
         desc = "Split Terminal (Horizontal)",
      },
      {
         "<C-_>",
         function()
            Snacks.terminal()
         end,
         desc = "which_key_ignore",
      },
      {
         "<leader>N",
         desc = "Neovim News",
         function()
            Snacks.win({
               file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
               width = 0.6,
               height = 0.6,
               wo = {
                  spell = false,
                  wrap = false,
                  signcolumn = "yes",
                  statuscolumn = " ",
                  conceallevel = 3,
               },
            })
         end,
      },
   },
   init = function()
      vim.api.nvim_create_autocmd("User", {
         pattern = "VeryLazy",
         callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
               Snacks.debug.inspect(...)
            end
            _G.bt = function()
               Snacks.debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command
         end,
      })
   end,
}
