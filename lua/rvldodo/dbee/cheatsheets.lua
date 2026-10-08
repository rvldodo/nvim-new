-- Command cheatsheets for the dbee drawer's help section (and <leader>qh).
-- Plain text with `--` comments, shown as sql in a floating window.

local M = {}

M.order = { "redis", "postgres", "mysql", "sqlserver" }

M.titles = {
   redis = "Redis",
   postgres = "PostgreSQL",
   mysql = "MySQL",
   sqlserver = "SQL Server",
}

M.sheets = {}

M.sheets.redis = [[
-- REDIS — one command per line; cursor on it + BB (or V + BB)
-- DB number is in the url (/0 .. /15); SELECT doesn't stick between calls.

-- ── Find keys ────────────────────────────────────────────────
DBSIZE                                   -- number of keys in this db
INFO keyspace                            -- key count per db
KEYS *                                   -- all keys (blocks server: small dbs only)
KEYS user:*                              -- by pattern  (* ? [abc])
SCAN 0 COUNT 1000                        -- safe iteration; rerun with returned cursor until 0
SCAN 0 MATCH user:* COUNT 1000           -- filtered scan
SCAN 0 TYPE hash COUNT 1000              -- only hashes
RANDOMKEY                                -- sample a key

-- ── Inspect a key ────────────────────────────────────────────
EXISTS key                               -- 1 / 0
TYPE key                                 -- string|hash|list|set|zset|stream
TTL key                                  -- seconds left (-1 no expiry, -2 missing)
PTTL key                                 -- ms left
MEMORY USAGE key                         -- bytes
OBJECT ENCODING key
OBJECT IDLETIME key                      -- seconds since last access

-- ── Strings ──────────────────────────────────────────────────
GET key
MGET k1 k2 k3
SET key value
SET key value EX 60                      -- with expiry (seconds)
SET key value NX                         -- only if missing
SETEX key 60 value
GETDEL key
GETEX key EX 60
INCR key
INCRBY key 5
DECR key
APPEND key value
STRLEN key

-- ── Hashes ───────────────────────────────────────────────────
HGETALL key
HGET key field
HMGET key f1 f2
HSET key field value
HDEL key field
HKEYS key
HVALS key
HLEN key
HEXISTS key field
HINCRBY key field 1
HSCAN key 0 MATCH a* COUNT 100

-- ── Lists ────────────────────────────────────────────────────
LRANGE key 0 -1                          -- all items
LRANGE key 0 9                           -- first 10
LLEN key
LINDEX key 0
LPUSH key value
RPUSH key value
LPOP key
RPOP key
LREM key 0 value                         -- remove all matching
LTRIM key 0 99                           -- keep first 100

-- ── Sets ─────────────────────────────────────────────────────
SMEMBERS key
SCARD key
SISMEMBER key value
SADD key value
SREM key value
SINTER k1 k2
SUNION k1 k2
SDIFF k1 k2
SSCAN key 0 COUNT 100

-- ── Sorted sets ──────────────────────────────────────────────
ZRANGE key 0 -1 WITHSCORES
ZREVRANGE key 0 9 WITHSCORES             -- top 10
ZRANGEBYSCORE key 0 100 WITHSCORES
ZSCORE key member
ZRANK key member
ZCARD key
ZCOUNT key 0 100
ZADD key 10 member
ZINCRBY key 1 member
ZREM key member

-- ── Streams ──────────────────────────────────────────────────
XLEN key
XRANGE key - + COUNT 10                  -- oldest
XREVRANGE key + - COUNT 10               -- newest
XINFO STREAM key
XINFO GROUPS key
XPENDING key group

-- ── Expiry / key management ──────────────────────────────────
EXPIRE key 60
PERSIST key                              -- remove expiry
RENAME key newkey
COPY src dst
DEL key                                  -- blocking delete
UNLINK key                               -- background delete (big keys)

-- ── Server / debugging ───────────────────────────────────────
PING
INFO
INFO memory
INFO server
CLIENT LIST
SLOWLOG GET 10
CONFIG GET maxmemory
MEMORY STATS
LATENCY DOCTOR
COMMAND LIST                             -- every command
COMMAND DOCS GET                         -- docs for one command

-- ── ⚠ DANGEROUS ──────────────────────────────────────────────
-- FLUSHDB    wipes this db          FLUSHALL   wipes every db
-- CONFIG SET changes live server    SHUTDOWN / DEBUG
]]

M.sheets.postgres = [[
-- POSTGRESQL — BB runs the note, V + BB the selection
-- Psql backslash commands (\dt, \d) don't work here; use the queries below.

-- ── Explore ──────────────────────────────────────────────────
SELECT current_database(), current_user, version();
SELECT datname FROM pg_database WHERE NOT datistemplate;          -- databases
SELECT schema_name FROM information_schema.schemata;              -- schemas
SELECT table_schema, table_name FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema') ORDER BY 1, 2;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns WHERE table_name = 'users' ORDER BY ordinal_position;
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'users';
SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
WHERE conrelid = 'public.users'::regclass;                         -- constraints / FKs
SELECT viewname FROM pg_views WHERE schemaname = 'public';
SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public';

-- ── Query ────────────────────────────────────────────────────
SELECT * FROM users LIMIT 100;
SELECT * FROM users WHERE email ILIKE '%@gmail.com' ORDER BY created_at DESC LIMIT 50;
SELECT status, count(*) FROM orders GROUP BY status HAVING count(*) > 10;
SELECT u.id, u.name, o.total FROM users u JOIN orders o ON o.user_id = u.id;
SELECT DISTINCT ON (user_id) * FROM orders ORDER BY user_id, created_at DESC;  -- latest per user
WITH recent AS (SELECT * FROM orders WHERE created_at > now() - interval '7 days')
SELECT count(*) FROM recent;
SELECT id, total, row_number() OVER (PARTITION BY user_id ORDER BY total DESC) FROM orders;
SELECT data->>'name' AS name FROM events WHERE data @> '{"type": "login"}';     -- jsonb

-- ── Modify ───────────────────────────────────────────────────
INSERT INTO users (name, email) VALUES ('a', 'a@x.com') RETURNING *;
INSERT INTO users (id, name) VALUES (1, 'a') ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
UPDATE users SET name = 'b' WHERE id = 1 RETURNING *;
DELETE FROM users WHERE id = 1 RETURNING *;
BEGIN;  /* ... */  COMMIT;   -- or ROLLBACK;

-- ── Schema ───────────────────────────────────────────────────
CREATE TABLE items (id bigserial PRIMARY KEY, name text NOT NULL, created_at timestamptz DEFAULT now());
ALTER TABLE items ADD COLUMN price numeric(10,2);
ALTER TABLE items RENAME COLUMN name TO title;
ALTER TABLE items ALTER COLUMN price SET DEFAULT 0;
CREATE INDEX CONCURRENTLY idx_items_title ON items (title);
DROP TABLE IF EXISTS items;

-- ── Performance / admin ──────────────────────────────────────
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'a@x.com';
SELECT pid, state, now() - query_start AS runtime, query FROM pg_stat_activity
WHERE state <> 'idle' ORDER BY runtime DESC;                      -- running queries
SELECT pg_cancel_backend(12345);                                  -- cancel query
SELECT pg_terminate_backend(12345);                               -- kill session
SELECT relname, pg_size_pretty(pg_total_relation_size(relid)) FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC LIMIT 20;             -- biggest tables
SELECT pg_size_pretty(pg_database_size(current_database()));
SELECT relname, n_live_tup, n_dead_tup, last_autovacuum FROM pg_stat_user_tables;
SELECT * FROM pg_locks WHERE NOT granted;                         -- waiting locks
VACUUM ANALYZE users;
SELECT usename FROM pg_user;                                      -- users / roles

-- ── ⚠ DANGEROUS ──────────────────────────────────────────────
-- DROP TABLE / DROP DATABASE / TRUNCATE
-- UPDATE or DELETE without WHERE
]]

M.sheets.mysql = [[
-- MYSQL / MARIADB — BB runs the note, V + BB the selection

-- ── Explore ──────────────────────────────────────────────────
SELECT DATABASE(), USER(), VERSION();
SHOW DATABASES;
USE mydb;
SHOW TABLES;
SHOW FULL TABLES WHERE Table_type = 'VIEW';
DESCRIBE users;                                   -- columns
SHOW COLUMNS FROM users;
SHOW CREATE TABLE users;                          -- full DDL
SHOW INDEX FROM users;
SELECT table_name, column_name, referenced_table_name, referenced_column_name
FROM information_schema.key_column_usage
WHERE table_schema = DATABASE() AND referenced_table_name IS NOT NULL;  -- foreign keys
SHOW PROCEDURE STATUS WHERE Db = DATABASE();
SHOW FUNCTION STATUS WHERE Db = DATABASE();
SHOW TRIGGERS;

-- ── Query ────────────────────────────────────────────────────
SELECT * FROM users LIMIT 100;
SELECT * FROM users WHERE email LIKE '%@gmail.com' ORDER BY created_at DESC LIMIT 50;
SELECT status, COUNT(*) FROM orders GROUP BY status HAVING COUNT(*) > 10;
SELECT u.id, u.name, o.total FROM users u JOIN orders o ON o.user_id = u.id;
SELECT id, total, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY total DESC) FROM orders;  -- 8.0+
SELECT data->>'$.name' FROM events WHERE JSON_EXTRACT(data, '$.type') = 'login';           -- json
SELECT * FROM orders WHERE created_at > NOW() - INTERVAL 7 DAY;

-- ── Modify ───────────────────────────────────────────────────
INSERT INTO users (name, email) VALUES ('a', 'a@x.com');
INSERT INTO users (id, name) VALUES (1, 'a') ON DUPLICATE KEY UPDATE name = VALUES(name);
UPDATE users SET name = 'b' WHERE id = 1;
DELETE FROM users WHERE id = 1;
SELECT LAST_INSERT_ID();
START TRANSACTION;  /* ... */  COMMIT;   -- or ROLLBACK;

-- ── Schema ───────────────────────────────────────────────────
CREATE TABLE items (id BIGINT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);
ALTER TABLE items ADD COLUMN price DECIMAL(10,2);
ALTER TABLE items RENAME COLUMN name TO title;    -- 8.0+
ALTER TABLE items MODIFY price DECIMAL(12,2) NOT NULL DEFAULT 0;
CREATE INDEX idx_items_title ON items (title);
DROP TABLE IF EXISTS items;

-- ── Performance / admin ──────────────────────────────────────
EXPLAIN SELECT * FROM users WHERE email = 'a@x.com';
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'a@x.com';   -- 8.0.18+
SHOW FULL PROCESSLIST;                            -- running queries
KILL 12345;                                       -- kill connection
KILL QUERY 12345;                                 -- cancel query only
SELECT table_name, ROUND((data_length + index_length) / 1024 / 1024, 1) AS mb
FROM information_schema.tables WHERE table_schema = DATABASE() ORDER BY mb DESC;  -- table sizes
SHOW TABLE STATUS;
SHOW VARIABLES LIKE 'max_connections';
SHOW GLOBAL STATUS LIKE 'Threads_connected';
SHOW ENGINE INNODB STATUS;                        -- locks / deadlocks
SELECT user, host FROM mysql.user;
SHOW GRANTS FOR CURRENT_USER();

-- ── ⚠ DANGEROUS ──────────────────────────────────────────────
-- DROP TABLE / DROP DATABASE / TRUNCATE
-- UPDATE or DELETE without WHERE
]]

M.sheets.sqlserver = [[
-- SQL SERVER (T-SQL) — BB runs the note, V + BB the selection
-- No GO separators: run one batch at a time.
-- Stored procedures: <leader>qp edit, <leader>qP new, <leader>qf run buffer.

-- ── Explore ──────────────────────────────────────────────────
SELECT DB_NAME() AS db, SUSER_SNAME() AS login, @@VERSION AS version;
SELECT name FROM sys.databases;
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY 1, 2;
SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS;
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Users' ORDER BY ORDINAL_POSITION;
EXEC sp_help 'dbo.Users';                        -- columns, indexes, constraints
EXEC sp_helpindex 'dbo.Users';
SELECT fk.name, OBJECT_NAME(fk.parent_object_id) AS [table], OBJECT_NAME(fk.referenced_object_id) AS ref
FROM sys.foreign_keys fk;
SELECT s.name + '.' + p.name AS proc_name FROM sys.procedures p JOIN sys.schemas s ON s.schema_id = p.schema_id;
EXEC sp_helptext 'dbo.MyProc';                   -- procedure / view source
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.MyProc'));

-- ── Query ────────────────────────────────────────────────────
SELECT TOP 100 * FROM dbo.Users;
SELECT * FROM dbo.Users ORDER BY CreatedAt DESC OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY;  -- paging
SELECT Status, COUNT(*) FROM dbo.Orders GROUP BY Status HAVING COUNT(*) > 10;
SELECT u.Id, u.Name, o.Total FROM dbo.Users u JOIN dbo.Orders o ON o.UserId = u.Id;
SELECT Id, Total, ROW_NUMBER() OVER (PARTITION BY UserId ORDER BY Total DESC) AS rn FROM dbo.Orders;
SELECT * FROM dbo.Orders WHERE CreatedAt > DATEADD(DAY, -7, GETDATE());
SELECT JSON_VALUE(Data, '$.name') FROM dbo.Events;
SELECT * FROM dbo.Users WITH (NOLOCK);           -- dirty read, doesn't block writers

-- ── Modify ───────────────────────────────────────────────────
INSERT INTO dbo.Users (Name, Email) OUTPUT INSERTED.* VALUES ('a', 'a@x.com');
UPDATE dbo.Users SET Name = 'b' OUTPUT INSERTED.* WHERE Id = 1;
DELETE FROM dbo.Users OUTPUT DELETED.* WHERE Id = 1;
MERGE dbo.Users AS t USING (SELECT 1 AS Id, 'a' AS Name) AS s ON t.Id = s.Id
WHEN MATCHED THEN UPDATE SET Name = s.Name WHEN NOT MATCHED THEN INSERT (Id, Name) VALUES (s.Id, s.Name);
SELECT SCOPE_IDENTITY();
BEGIN TRAN;  /* ... */  COMMIT;   -- or ROLLBACK;
EXEC dbo.MyProc @Id = 1;

-- ── Schema ───────────────────────────────────────────────────
CREATE TABLE dbo.Items (Id INT IDENTITY(1,1) PRIMARY KEY, Name NVARCHAR(255) NOT NULL,
  CreatedAt DATETIME2 DEFAULT SYSUTCDATETIME());
ALTER TABLE dbo.Items ADD Price DECIMAL(10,2) NULL;
ALTER TABLE dbo.Items ALTER COLUMN Price DECIMAL(12,2) NOT NULL;
EXEC sp_rename 'dbo.Items.Name', 'Title', 'COLUMN';
CREATE INDEX IX_Items_Title ON dbo.Items (Title);
DROP TABLE IF EXISTS dbo.Items;                  -- 2016+

-- ── Performance / admin ──────────────────────────────────────
SET STATISTICS IO ON;                            -- then run query, see Messages
SELECT session_id, status, command, wait_type, blocking_session_id, total_elapsed_time
FROM sys.dm_exec_requests WHERE session_id > 50;  -- running queries
EXEC sp_who2;                                    -- sessions + blocking
KILL 53;                                         -- kill session
SELECT t.name, SUM(p.rows) AS rows, SUM(a.total_pages) * 8 / 1024 AS mb
FROM sys.tables t JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
JOIN sys.allocation_units a ON a.container_id = p.partition_id
GROUP BY t.name ORDER BY mb DESC;                -- table sizes
EXEC sp_spaceused;
SELECT name, type_desc FROM sys.database_principals WHERE type IN ('S', 'U', 'G');  -- users

-- ── ⚠ DANGEROUS ──────────────────────────────────────────────
-- DROP TABLE / DROP DATABASE / TRUNCATE TABLE
-- UPDATE or DELETE without WHERE
]]

--- Open one cheatsheet in a centered read-only float. q / <Esc> closes.
---@param name string key of M.sheets
function M.open(name)
   local text = M.sheets[name]
   if not text then return end
   local lines = vim.split(vim.trim(text), "\n")

   local buf = vim.api.nvim_create_buf(false, true)
   vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
   vim.bo[buf].modifiable = false
   vim.bo[buf].bufhidden = "wipe"
   vim.bo[buf].filetype = "sql"

   local width = math.min(120, vim.o.columns - 8)
   local height = math.min(#lines, vim.o.lines - 6)
   local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = math.floor((vim.o.lines - height) / 2) - 1,
      col = math.floor((vim.o.columns - width) / 2),
      border = "rounded",
      title = " " .. M.titles[name] .. " cheatsheet  ·  yy to copy · q to close ",
      title_pos = "center",
   })
   vim.wo[win].wrap = false
   vim.wo[win].cursorline = true

   for _, key in ipairs({ "q", "<Esc>" }) do
      vim.keymap.set("n", key, function() vim.api.nvim_win_close(win, true) end, { buffer = buf, nowait = true })
   end
end

--- Pick a cheatsheet with vim.ui.select.
function M.pick()
   vim.ui.select(M.order, {
      prompt = "DB cheatsheet",
      format_item = function(name) return M.titles[name] end,
   }, function(name)
      if name then M.open(name) end
   end)
end

return M
