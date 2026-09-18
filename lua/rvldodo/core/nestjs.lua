-- `:NestGen [schematic] [name] [flags...]` — run the Nest CLI generator
-- without leaving the editor.
--
-- The CLI is interactive for `resource` (transport layer, CRUD y/n), so it
-- runs in a split terminal rather than a job whose prompts you'd never see.
-- Called with no args it asks for schematic + name via vim.ui.
--
-- Snippets (snippets/nestjs.lua) cover the "I already have the file" case;
-- this covers "make me the file, register it in the module, and add the spec".

local ts = require("rvldodo.core.typescript")

local SCHEMATICS = {
   "resource", -- module + controller + service + dto + entity + specs
   "module",
   "controller",
   "service",
   "provider",
   "guard",
   "interceptor",
   "pipe",
   "middleware",
   "filter",
   "decorator",
   "gateway", -- websockets
   "resolver", -- graphql
   "class",
   "interface",
   "library",
   "sub-app",
}

local function run(args)
   local root = ts.project_root()
   if not ts.is_nest() then
      vim.notify("Not inside a NestJS project (no nest-cli.json / @nestjs/core)", vim.log.levels.WARN)
      return
   end

   -- Project-local CLI first: `nest g` writes files relative to nest-cli.json's
   -- sourceRoot, and the local version matches the project's schematics.
   local nest = ts.local_bin("nest") or (vim.fn.executable("nest") == 1 and "nest") or nil
   if not nest then
      vim.notify(
         "@nestjs/cli not found (install it: " .. ts.package_manager() .. " add -D @nestjs/cli)",
         vim.log.levels.ERROR
      )
      return
   end

   local cmd = { nest, "generate" }
   vim.list_extend(cmd, args)

   vim.cmd("botright 12split")
   vim.cmd("enew")
   vim.fn.jobstart(cmd, {
      term = true,
      cwd = root,
      on_exit = function(_, code)
         if code == 0 then
            -- Reload any open buffer the generator touched (e.g. app.module.ts
            -- gets the new module added to `imports`).
            vim.schedule(function()
               vim.cmd("checktime")
            end)
         end
      end,
   })
   vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("NestGen", function(cmd)
   if #cmd.fargs > 0 then
      run(cmd.fargs)
      return
   end

   vim.ui.select(SCHEMATICS, { prompt = "nest generate" }, function(schematic)
      if not schematic then
         return
      end
      vim.ui.input({ prompt = ("nest g %s <name>: "):format(schematic) }, function(name)
         if not name or name == "" then
            return
         end
         run({ schematic, name })
      end)
   end)
end, {
   nargs = "*",
   desc = "Run the Nest CLI generator",
   complete = function(_, line)
      -- Complete the schematic only; the name is free text.
      local words = vim.split(line, "%s+", { trimempty = true })
      if #words > 2 or (#words == 2 and line:sub(-1) == " ") then
         return {}
      end
      return SCHEMATICS
   end,
})

vim.api.nvim_create_autocmd("FileType", {
   group = vim.api.nvim_create_augroup("NestJsKeymaps", { clear = true }),
   pattern = { "typescript", "javascript" },
   callback = function(ev)
      vim.keymap.set("n", "<leader>ng", "<cmd>NestGen<CR>", { buffer = ev.buf, desc = "Nest: generate (nest g)" })
   end,
})
