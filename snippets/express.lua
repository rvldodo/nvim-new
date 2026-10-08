-- Express snippets. Loaded by the LuaSnip from_lua loader under the pseudo
-- filetype `express`, which plugins/nvim-cmp.lua extends `javascript` and
-- `typescript` with.
--
-- Triggers are `ex<thing>` (exapp, exrouter, exget, exmw, …). Imports and
-- exports follow the file: `require` / `module.exports` in a CommonJS
-- project, `import` / `export default` in an ESM one or in TypeScript
-- (core/typescript.lua → module_type).

local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmt

local function esm()
   return require("rvldodo.core.typescript").module_type() == "esm"
end

--- `const express = require('express');` / `import express from 'express';`
local function import(name, module)
   return f(function()
      if esm() then
         return ("import %s from '%s';"):format(name, module)
      end
      return ("const %s = require('%s');"):format(name, module)
   end)
end

--- `module.exports = x;` / `export default x;`
local function export(name)
   return f(function()
      return esm() and ("export default %s;"):format(name) or ("module.exports = %s;"):format(name)
   end)
end

--- Type annotation in .ts files, nothing in .js.
local function ts_type(annotation)
   return f(function()
      return vim.bo.filetype == "typescript" and annotation or ""
   end)
end

local snippets = {}
local function add(trig, desc, nodes, opts)
   opts = opts or {}
   opts.repeat_duplicates = true
   snippets[#snippets + 1] = s({ trig = trig, name = trig, desc = desc }, fmt(nodes[1], nodes[2], opts))
end

-- scaffolds ---------------------------------------------------------------

add("exapp", "Express app + listen", {
   [[
{import}

const app = express();
const PORT = process.env.PORT || {port};

app.use(express.json());
app.use(express.urlencoded({{ extended: true }}));

app.get('/health', (req, res) => {{
  res.json({{ status: 'ok' }});
}});
{body}
app.listen(PORT, () => {{
  console.log(`Server listening on http://localhost:${{PORT}}`);
}});
]],
   { import = import("express", "express"), port = i(1, "3000"), body = i(0) },
})

add("exrouter", "Express router module", {
   [[
{import}

const router = express.Router();

router.get('/{path}', async (req, res) => {{
  {body}
}});

{export}
]],
   { import = import("express", "express"), path = i(1), body = i(0), export = export("router") },
})

add("exreq", "import express", {
   "{import}",
   { import = import("express", "express") },
})

-- routes ------------------------------------------------------------------

for _, method in ipairs({ "get", "post", "put", "patch", "delete" }) do
   add("ex" .. method, ("%s route handler"):format(method:upper()), {
      [[
{obj}.{method}('{path}', async (req{reqT}, res{resT}) => {{
  {body}
}});
]],
      {
         obj = c(1, { t("router"), t("app") }),
         method = t(method),
         path = i(2, "/"),
         reqT = ts_type(": Request"),
         resT = ts_type(": Response"),
         body = i(0),
      },
   })
end

add("exroute", "router.route() chain", {
   [[
router
  .route('{path}')
  .get(async (req, res) => {{
    {body}
  }})
  .post(async (req, res) => {{}});
]],
   { path = i(1, "/"), body = i(0) },
})

add("exuse", "mount a router", {
   "app.use('{prefix}', {router});",
   { prefix = i(1, "/api"), router = i(2, "router") },
})

-- middleware --------------------------------------------------------------

add("exmw", "middleware (req, res, next)", {
   [[
function {name}(req{reqT}, res{resT}, next{nextT}) {{
  {body}
  next();
}}
]],
   {
      name = i(1, "middleware"),
      reqT = ts_type(": Request"),
      resT = ts_type(": Response"),
      nextT = ts_type(": NextFunction"),
      body = i(0),
   },
})

add("exerr", "error-handling middleware (4 args)", {
   [[
// eslint-disable-next-line no-unused-vars
app.use((err{errT}, req{reqT}, res{resT}, next{nextT}) => {{
  console.error(err);
  res.status(err.status || 500).json({{ message: err.message || 'Internal Server Error' }});
}});
]],
   {
      errT = ts_type(": any"),
      reqT = ts_type(": Request"),
      resT = ts_type(": Response"),
      nextT = ts_type(": NextFunction"),
   },
})

add("ex404", "404 fallthrough handler", {
   [[
app.use((req, res) => {{
  res.status(404).json({{ message: `Not found: ${{req.method}} ${{req.originalUrl}}` }});
}});
]],
   {},
})

add("exasync", "asyncHandler wrapper (forward rejections to next)", {
   [[
const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
]],
   {},
})

-- responses ---------------------------------------------------------------

add("exjson", "res.status().json()", {
   "res.status({status}).json({body});",
   { status = i(1, "200"), body = i(0, "data") },
})

add("exparams", "destructure req.params / query / body", {
   "const {{ {fields} }} = req.{src};",
   { fields = i(2), src = c(1, { t("params"), t("query"), t("body") }) },
})

-- tests (supertest) -------------------------------------------------------

add("extest", "supertest request spec", {
   [[
{reqImport}
{appImport}

describe('{method} {path}', () => {{
  it('{desc}', async () => {{
    const res = await request(app).{lmethod}('{path2}');
    expect(res.status).toBe({status});
    {body}
  }});
}});
]],
   {
      reqImport = import("request", "supertest"),
      appImport = import("app", "../app"),
      method = i(1, "GET"),
      path = i(2, "/"),
      desc = i(3, "responds with 200"),
      lmethod = f(function(args)
         return args[1][1]:lower()
      end, { 1 }),
      path2 = f(function(args)
         return args[1][1]
      end, { 2 }),
      status = i(4, "200"),
      body = i(0),
   },
})

return snippets
