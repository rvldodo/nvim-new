-- Database client: browse connections/tables, run queries, view + export
-- results. Backend is a Go binary installed by `build` (re-run with
-- :lua require("dbee").install() if it fails).
--
-- Connections are read from (and added via the UI to)
--   1. $DBEE_CONNECTIONS (JSON array) — handy for per-project direnv
--   2. stdpath("state")/dbee/persistence.json
-- Entry shape: { "name": "local pg", "type": "postgres",
--                "url": "postgres://user:pass@localhost:5432/db?sslmode=disable" }
-- url supports {{ env "PG_PASSWORD" }} templating to keep secrets out of the file.
--
-- Postgres: append &idle_in_transaction_session_timeout=10000 to the url.
-- dbee runs queries on a connection pool, so a script that dies between
-- BEGIN and COMMIT leaves a pooled session in an aborted transaction and
-- every later call (table list included) fails with "current transaction is
-- aborted". The timeout makes the server drop that session; the next call
-- errors once with "bad connection" and then works again.
--
-- Inside the dbee editor: BB runs the file (n) / selection (v).
-- From any .sql buffer: <leader>qe runs the statement under the cursor
-- (paragraph) or the visual selection on the current connection.
--
-- SQL Server stored procedures (the drawer can't show them):
--   <leader>qp  pick one -> opens its source as CREATE OR ALTER in a sql buffer
--   <leader>qP  new procedure from a template
-- Edit, then <leader>qf to run the whole buffer (keep it to the one
-- CREATE OR ALTER statement — no GO separators).

-- Run `query` on the current connection without touching the result UI and
-- call `cb` with the rows decoded from JSON (list of { column = value }).
local function query_rows(query, cb)
   local core = require("dbee").api.core
   local conn = core.get_current_connection()
   if not conn then
      return vim.notify("dbee: no connection selected", vim.log.levels.ERROR)
   end

   local call = core.connection_execute(conn.id, query)
   local done = false
   core.register_event_listener("call_state_changed", function(data)
      if done or data.call.id ~= call.id then return end
      local state = data.call.state
      if state == "archived" then
         done = true
         vim.schedule(function()
            local tmp = vim.fn.tempname()
            core.call_store_result(call.id, "json", "file", { extra_arg = tmp })
            local ok, rows = pcall(vim.json.decode, table.concat(vim.fn.readfile(tmp), "\n"))
            vim.fn.delete(tmp)
            cb(ok and rows ~= vim.NIL and rows or {})
         end)
      elseif state:match("failed$") or state == "canceled" then
         done = true
         vim.schedule(function()
            vim.notify("dbee: query " .. state .. ": " .. (data.call.error or ""), vim.log.levels.ERROR)
         end)
      end
   end)
end

local function open_sql_buffer(name, text)
   vim.cmd.enew()
   vim.bo.buftype = "nofile"
   vim.bo.filetype = "sql"
   pcall(vim.api.nvim_buf_set_name, 0, "dbee://" .. name)
   vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(text, "\r?\n"))
end

local function edit_procedure()
   query_rows([[
SELECT s.name + '.' + p.name AS name
FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id
ORDER BY s.name, p.name]], function(rows)
      local names = vim.tbl_map(function(r) return r.name end, rows)
      vim.ui.select(names, { prompt = "Stored procedure" }, function(name)
         if not name then return end
         query_rows(
            ("SELECT OBJECT_DEFINITION(OBJECT_ID('%s')) AS def"):format(name:gsub("'", "''")),
            function(def_rows)
               local def = def_rows[1] and def_rows[1].def
               if type(def) ~= "string" then
                  return vim.notify("dbee: no definition for " .. name .. " (encrypted or no permission?)", vim.log.levels.WARN)
               end
               -- Turn the stored CREATE into CREATE OR ALTER so running it updates in place.
               def = def:gsub("^(%s*)[Cc][Rr][Ee][Aa][Tt][Ee]%s+[Pp][Rr][Oo][Cc]", "%1CREATE OR ALTER PROC", 1)
               open_sql_buffer(name .. ".sql", def)
            end
         )
      end)
   end)
end

local function new_procedure()
   local name = vim.fn.input("Procedure name: ", "dbo.")
   if name == "" then return end
   open_sql_buffer(name .. ".sql", ([[
CREATE OR ALTER PROCEDURE %s
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @Id AS Id;
END]]):format(name))
end

return {
   {
      "kndndrj/nvim-dbee",
      dependencies = {
         "MunifTanjim/nui.nvim",
      },
      cmd = "Dbee",
      build = function()
         -- Build from the plugin's own source with Go. The prebuilt binary
         -- that install() downloads is pinned to a July 2024 commit and
         -- misses later fixes (e.g. redis:// urls: "too many colons in
         -- address"). Other methods: "curl", "wget", "bitsadmin".
         require("dbee").install("go")
      end,
      keys = {
         { "<leader>qq", function() require("dbee").toggle() end, desc = "DB: toggle UI" },
         {
            "<leader>qe",
            function()
               local query = table.concat(vim.fn.getline("'{", "'}"), "\n")
               require("dbee").execute(vim.trim(query))
            end,
            desc = "DB: run statement under cursor",
         },
         {
            "<leader>qe",
            function()
               -- Leave visual mode first so '< '> marks are up to date.
               vim.cmd('normal! \27')
               local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
               local lines = vim.fn.getregion(s, e, { type = vim.fn.visualmode() })
               require("dbee").execute(table.concat(lines, "\n"))
            end,
            mode = "v",
            desc = "DB: run selection",
         },
         {
            "<leader>qf",
            function()
               require("dbee").execute(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))
            end,
            desc = "DB: run whole buffer",
         },
         { "<leader>qh", function() require("rvldodo.dbee.cheatsheets").pick() end, desc = "DB: command cheatsheets" },
         { "<leader>qp", edit_procedure, desc = "DB: edit stored procedure (SQL Server)" },
         { "<leader>qP", new_procedure, desc = "DB: new stored procedure (SQL Server)" },
         { "<leader>qc", function() require("dbee").store("csv", "file", { extra_arg = vim.fn.input("CSV path: ", "", "file") }) end, desc = "DB: export result to CSV" },
         { "<leader>qj", function() require("dbee").store("json", "yank", {}) end, desc = "DB: yank result as JSON" },
      },
      config = function()
         -- Per-database icons for connection nodes in the drawer. dbee picks a
         -- node's icon by node.type and every connection is just "connection",
         -- so retag each one as "conn_<db>" and give those types their own candy.
         -- Brand colors, brightened to read well on a dark background.
         local db_icons = {
            postgres   = { icon = "\u{e76e}", color = "#6ea8ff" },
            mysql      = { icon = "\u{e704}", color = "#4fd6be" },
            sqlite     = { icon = "\u{e7c4}", color = "#86e1fc" },
            sqlserver  = { icon = "\u{e77c}", color = "#ff757f" },
            redis      = { icon = "\u{e76d}", color = "#ff5f56" },
            mongo      = { icon = "\u{e7a4}", color = "#c3e88d" },
            redshift   = { icon = "\u{e7ad}", color = "#ff966c" },
            oracle     = { icon = "\u{f01bc}", color = "#ff6e6e" },
            bigquery   = { icon = "\u{f01bc}", color = "#82aaff" },
            clickhouse = { icon = "\u{f01bc}", color = "#ffc777" },
            databricks = { icon = "\u{f01bc}", color = "#ff8a65" },
            duckdb     = { icon = "\u{f01bc}", color = "#fff59d" },
         }

         -- Colors for the rest of the drawer (tokyonight-moon palette).
         -- { icon color, text color }; text nil = normal fg.
         local node_colors = {
            source            = { "#ff966c", "#ff966c" },
            add               = { "#c3e88d", "#c3e88d" },
            edit              = { "#82aaff", "#82aaff" },
            remove            = { "#ff757f", "#ff757f" },
            help              = { "#ffc777", "#ffc777" },
            note              = { "#ffc777" },
            history           = { "#c099ff" },
            database_switch   = { "#c3e88d", "#c3e88d" },
            schema            = { "#c099ff", "#c099ff" },
            table             = { "#82aaff" },
            view              = { "#86e1fc" },
            materialized_view = { "#4fd6be" },
            streaming_table   = { "#ff966c" },
            managed           = { "#fca7ea" },
            sink              = { "#ff966c" },
            column            = { "#ffc777" },
            none_dir          = { "#c099ff" },
            node_expanded     = { "#636da6" },
            node_closed       = { "#636da6" },
         }

         local function set_highlights()
            for db, spec in pairs(db_icons) do
               vim.api.nvim_set_hl(0, "DbeeConn_" .. db, { fg = spec.color, bold = true })
            end
            for kind, c in pairs(node_colors) do
               vim.api.nvim_set_hl(0, "DbeeIcon_" .. kind, { fg = c[1] })
               if c[2] then
                  vim.api.nvim_set_hl(0, "DbeeText_" .. kind, { fg = c[2] })
               end
            end
         end
         set_highlights()
         -- :colorscheme clears custom groups; put them back.
         vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
         -- dbee accepts several names per adapter; map them to one key.
         local aliases = {
            pg = "postgres", postgresql = "postgres",
            sqlite3 = "sqlite",
            mssql = "sqlserver",
            mongodb = "mongo",
            duck = "duckdb",
         }

         -- Fail fast on unreachable hosts (VPN off, server down). dbee talks to
         -- its backend synchronously, so the first query on a dead connection
         -- (table list, completion, ...) freezes nvim for the OS TCP timeout
         -- (~75s on macOS) unless the driver has its own connect timeout.
         -- Applied when connections are loaded; urls that already set one are
         -- left alone.
         local timeout_param = {
            postgres = "connect_timeout",
            redshift = "connect_timeout",
            sqlserver = "dial+timeout",
         }
         local function with_timeout(conn)
            local t = (conn.type or ""):lower()
            local key = timeout_param[aliases[t] or t]
            local url = conn.url
            if key and type(url) == "string" and url:find("://", 1, true)
               and not url:find(key, 1, true) and not url:find(key:gsub("%+", " "), 1, true) then
               conn.url = url .. (url:find("?", 1, true) and "&" or "?") .. key .. "=3"
            end
            return conn
         end
         local sources = require("dbee.sources")
         for _, src in ipairs({ sources.FileSource, sources.EnvSource }) do
            local load = src.load
            src.load = function(self)
               return vim.tbl_map(with_timeout, load(self))
            end
         end

         local candies = {}
         for db, spec in pairs(db_icons) do
            local hl = "DbeeConn_" .. db
            candies["conn_" .. db] = { icon = spec.icon, icon_highlight = hl, text_highlight = hl }
         end
         -- Only the highlights change here; setup() deep-merges, so dbee's
         -- default icons for these node types are kept.
         for kind, c in pairs(node_colors) do
            candies[kind] = {
               icon_highlight = "DbeeIcon_" .. kind,
               text_highlight = c[2] and ("DbeeText_" .. kind) or "",
            }
         end

         local convert = require("dbee.ui.drawer.convert")

         -- Command cheatsheets under the drawer's help node:
         --   help > cheatsheets > Redis | PostgreSQL | MySQL | SQL Server
         -- <CR> opens one in a float (also <leader>qh from anywhere).
         local NuiTree = require("nui.tree")
         local cheatsheets = require("rvldodo.dbee.cheatsheets")
         local help_node = convert.help_node
         convert.help_node = function(...)
            local node = help_node(...)
            local sheets = {}
            for _, name in ipairs(cheatsheets.order) do
               local sheet = NuiTree.Node({
                  id = "__cheatsheet_" .. name .. "__",
                  name = cheatsheets.titles[name],
                  type = "note",
               })
               sheet.action_1 = function() cheatsheets.open(name) end
               table.insert(sheets, sheet)
            end
            local parent = NuiTree.Node({
               id = "__cheatsheets__",
               name = "cheatsheets",
               type = "help",
            }, sheets)
            -- NuiTree nodes keep pending children here until set_nodes().
            table.insert(node.__children, 1, parent)
            return node
         end

         local handler_nodes = convert.handler_nodes
         convert.handler_nodes = function(handler, result)
            local nodes = handler_nodes(handler, result)
            local types = {}
            for _, source in ipairs(handler:get_sources()) do
               for _, conn in ipairs(handler:source_get_connections(source:name())) do
                  local t = (conn.type or ""):lower()
                  types[conn.id] = aliases[t] or t
               end
            end
            for _, source_node in ipairs(nodes) do
               for _, node in ipairs(source_node.__children or {}) do
                  local db = node.type == "connection" and types[node.id]
                  if db and candies["conn_" .. db] then
                     node.type = "conn_" .. db
                  end
               end
            end
            return nodes
         end

         -- dbee turns the current window into its editor. If that's the Snacks
         -- dashboard, every split dbee makes resizes it and the dashboard
         -- re-renders (re-running the ascii-image-converter terminal section),
         -- so the image flashes and nvim lags. Swap in an empty buffer first;
         -- the dashboard buffer is bufhidden=wipe, so its autocmds go with it.
         local Default = require("dbee.layouts").Default
         local default_open = Default.open
         Default.open = function(self, ...)
            if vim.bo.filetype == "snacks_dashboard" then
               vim.cmd.enew()
            end
            return default_open(self, ...)
         end

         -- dbee's redis adapter splits a command on single spaces only, so a
         -- trailing newline ends up inside the last argument (`KEYS *` from
         -- V+BB becomes the pattern "*\n" -> no results) and multi-line text
         -- turns into one garbage command. For redis connections, run one
         -- line with whitespace collapsed; with several lines (BB on the
         -- whole note) that's the line under the cursor.
         local Handler = require("dbee.handler")
         local connection_execute = Handler.connection_execute
         Handler.connection_execute = function(self, id, query)
            local params = self:connection_get_params(id) or {}
            if (params.type or ""):lower() == "redis" then
               local lines = vim.tbl_filter(function(l) return l ~= "" end,
                  vim.tbl_map(vim.trim, vim.split(query, "\n")))
               if #lines > 1 then
                  local cur = vim.trim(vim.api.nvim_get_current_line())
                  lines = { vim.tbl_contains(lines, cur) and cur or lines[1] }
               end
               query = (lines[1] or ""):gsub("%s+", " ")
            end
            return connection_execute(self, id, query)
         end

         -- setup() deep-merges with the defaults, so the other icons stay.
         require("dbee").setup({ drawer = { candies = candies } })

         -- Active connection indicator. Keeps vim.g.dbee_active up to date
         -- for the lualine component and pops a notification on every
         -- switch. Connections with "prod" in the name are flagged loudly.
         --   vim.g.dbee_active = { name, db, database, icon, color, prod }
         local core = require("dbee").api.core

         -- No database queries in here: they're synchronous, and on an
         -- unreachable host they'd block the UI. The database name comes from
         -- the database_selected event (or the url's path for postgres).
         local announced
         local function update_active(database, announce)
            local conn = core.get_current_connection()
            if not conn then
               vim.g.dbee_active = nil
               return
            end
            if not database then
               database = (conn.url or ""):match("^%w+://[^/]+/([^?/]+)")
                  or (conn.url or ""):match("[?&][Dd]atabase=([^&]+)")
            end
            -- dbee fires current_connection_changed once per connection while
            -- loading; only announce real changes.
            local key = conn.id .. "/" .. tostring(database)
            if announced == key then announce = false end
            announced = key

            local t = (conn.type or ""):lower()
            local db = aliases[t] or t
            local spec = db_icons[db] or { icon = "\u{f01bc}", color = "#c8d3f5" }
            local prod = conn.name:lower():find("prod") ~= nil
            vim.g.dbee_active = {
               name = conn.name,
               db = db,
               database = (database and database ~= "") and database or nil,
               icon = spec.icon,
               color = spec.color,
               prod = prod,
            }

            if announce then
               local target = conn.name .. (vim.g.dbee_active.database and (" → " .. database) or "")
               vim.notify(
                  ("%s %s (%s)%s"):format(spec.icon, target, db, prod and "\n⚠ PRODUCTION connection" or ""),
                  prod and vim.log.levels.WARN or vim.log.levels.INFO,
                  { title = "dbee" }
               )
            end
            vim.cmd.redrawstatus({ bang = true })
         end

         core.register_event_listener("current_connection_changed", function()
            vim.schedule(function() update_active(nil, true) end)
         end)
         core.register_event_listener("database_selected", function(data)
            vim.schedule(function() update_active(data.database_name, true) end)
         end)
         -- dbee restores the last connection on startup; show it without a popup.
         vim.schedule(function() update_active(nil, false) end)
      end,
   },

   -- Table / column / schema completion in sql buffers, fed by the
   -- current dbee connection.
   {
      "MattiasMTS/cmp-dbee",
      ft = "sql",
      dependencies = { "kndndrj/nvim-dbee", "hrsh7th/nvim-cmp" },
      config = function()
         require("cmp-dbee").setup({})
         local cmp = require("cmp")
         cmp.setup.filetype("sql", {
            sources = cmp.config.sources({
               { name = "cmp-dbee" },
               { name = "luasnip" },
            }, {
               { name = "buffer" },
               { name = "path" },
            }),
         })
      end,
   },
}
