-- NestJS snippets. Loaded by the LuaSnip from_lua loader under the pseudo
-- filetype `nestjs`, which plugins/nvim-cmp.lua extends `typescript` with.
--
-- Triggers are `n<thing>` (ncontroller, nservice, nget, …) rather than the
-- VSCode extension's `n-<thing>`: `-` is not a keyword character in TS, so a
-- dashed trigger never reaches nvim-cmp as one word.
--
-- Wherever a name can be derived from the filename it is pre-filled, so in
-- `users.controller.ts` → `ncontroller` yields `UsersController` on route
-- 'users' and you only Tab through what is actually a choice.

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

-- ── name helpers ────────────────────────────────────────────────────────

--- "create-user" -> "CreateUser"
local function pascal(str)
   return (str:gsub("(%a)([%w]*)", function(head, tail)
      return head:upper() .. tail
   end):gsub("[%-_]", ""))
end

--- "create-user" -> "createUser"
local function camel(str)
   local p = pascal(str)
   return p:sub(1, 1):lower() .. p:sub(2)
end

--- Naive singular for `nest g resource users` -> CreateUserDto naming.
local function singular(str)
   if str:match("ies$") then
      return str:sub(1, -4) .. "y"
   elseif str:match("[^s]s$") then
      return str:sub(1, -2)
   end
   return str
end

--- "users.controller.spec.ts" -> { "users", "controller" }
local function file_parts()
   local name = vim.fn.expand("%:t:r")
   if name == "" then
      return {}
   end
   name = name:gsub("%.e2e%-spec$", ""):gsub("%.spec$", ""):gsub("%.test$", "")
   return vim.split(name, ".", { plain = true })
end

--- First dotted segment: "users" for users.controller.ts. Falls back to `default`.
local function feature(default)
   local parts = file_parts()
   return parts[1] or default
end

--- Class name for this file: parts PascalCased and joined ("UsersController").
--- A single-segment file (users.ts) gets `suffix` appended.
local function class_name(suffix)
   local parts = file_parts()
   if #parts == 0 then
      return suffix
   end
   local out = {}
   for _, p in ipairs(parts) do
      out[#out + 1] = pascal(p)
   end
   if #parts == 1 and suffix ~= "" then
      out[#out + 1] = suffix
   end
   return table.concat(out)
end

--- Insert node pre-filled with a value computed at expansion time.
local function prefilled(idx, compute)
   return d(idx, function()
      return sn(nil, { i(1, compute()) })
   end)
end

local function name_node(idx, suffix)
   return prefilled(idx, function()
      return class_name(suffix)
   end)
end

local function feature_node(idx, default)
   return prefilled(idx, function()
      return feature(default)
   end)
end

--- Function node deriving text from the feature insert node at `argidx`.
local function from_feature(argidx, fn)
   return f(function(args)
      return fn(args[1][1] or "")
   end, { argidx })
end

-- ── snippets ────────────────────────────────────────────────────────────

local snippets = {}
local function add(trig, desc, nodes, opts)
   opts = opts or {}
   opts.repeat_duplicates = true
   snippets[#snippets + 1] = s({ trig = trig, name = trig, desc = desc }, fmt(nodes[1], nodes[2], opts))
end

-- class scaffolds ---------------------------------------------------------

add("ncontroller", "NestJS controller", {
   [[
import {{ Controller }} from '@nestjs/common';

@Controller('{route}')
export class {name} {{
  constructor({ctor}) {{}}
}}
]],
   { route = feature_node(1, "route"), name = name_node(2, "Controller"), ctor = i(3) },
})

add("nservice", "NestJS injectable service", {
   [[
import {{ Injectable }} from '@nestjs/common';

@Injectable()
export class {name} {{
  {body}
}}
]],
   { name = name_node(1, "Service"), body = i(0) },
})

add("nmodule", "NestJS module", {
   [[
import {{ Module }} from '@nestjs/common';

@Module({{
  imports: [{imports}],
  controllers: [{controllers}],
  providers: [{providers}],
  exports: [{exports}],
}})
export class {name} {{}}
]],
   {
      imports = i(1),
      controllers = prefilled(2, function()
         return pascal(feature("")) .. "Controller"
      end),
      providers = prefilled(3, function()
         return pascal(feature("")) .. "Service"
      end),
      exports = i(4),
      name = name_node(5, "Module"),
   },
})

add("nguard", "NestJS guard (CanActivate)", {
   [[
import {{ CanActivate, ExecutionContext, Injectable }} from '@nestjs/common';
import {{ Observable }} from 'rxjs';

@Injectable()
export class {name} implements CanActivate {{
  canActivate(context: ExecutionContext): boolean | Promise<boolean> | Observable<boolean> {{
    const request = context.switchToHttp().getRequest();
    {body}
    return true;
  }}
}}
]],
   { name = name_node(1, "Guard"), body = i(0) },
})

add("ninterceptor", "NestJS interceptor", {
   [[
import {{ CallHandler, ExecutionContext, Injectable, NestInterceptor }} from '@nestjs/common';
import {{ Observable, tap }} from 'rxjs';

@Injectable()
export class {name} implements NestInterceptor {{
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {{
    {before}
    return next.handle().pipe(tap(() => {after}));
  }}
}}
]],
   { name = name_node(1, "Interceptor"), before = i(2), after = i(0, "{}") },
})

add("npipe", "NestJS pipe (PipeTransform)", {
   [[
import {{ ArgumentMetadata, Injectable, PipeTransform }} from '@nestjs/common';

@Injectable()
export class {name} implements PipeTransform {{
  transform(value: {vtype}, metadata: ArgumentMetadata) {{
    {body}
    return value;
  }}
}}
]],
   { name = name_node(1, "Pipe"), vtype = i(2, "unknown"), body = i(0) },
})

add("nmiddleware", "NestJS middleware (express)", {
   [[
import {{ Injectable, NestMiddleware }} from '@nestjs/common';
import {{ NextFunction, Request, Response }} from 'express';

@Injectable()
export class {name} implements NestMiddleware {{
  use(req: Request, res: Response, next: NextFunction) {{
    {body}
    next();
  }}
}}
]],
   { name = name_node(1, "Middleware"), body = i(0) },
})

add("nfilter", "NestJS exception filter", {
   [[
import {{ ArgumentsHost, Catch, ExceptionFilter, HttpException }} from '@nestjs/common';
import {{ Response }} from 'express';

@Catch({exc})
export class {name} implements ExceptionFilter {{
  catch(exception: {exc}, host: ArgumentsHost) {{
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const status = exception.getStatus();

    response.status(status).json({{
      statusCode: status,
      timestamp: new Date().toISOString(),
      message: exception.message,
    }});
  }}
}}
]],
   { exc = i(1, "HttpException"), name = name_node(2, "Filter") },
})

add("ndecorator", "NestJS custom param decorator", {
   [[
import {{ createParamDecorator, ExecutionContext }} from '@nestjs/common';

export const {name} = createParamDecorator((data: unknown, ctx: ExecutionContext) => {{
  const request = ctx.switchToHttp().getRequest();
  return {body};
}});
]],
   {
      name = prefilled(1, function()
         return pascal(feature("Decorator"))
      end),
      body = i(0, "request.user"),
   },
})

add("ndto", "DTO with class-validator", {
   [[
import {{ IsNotEmpty, IsString }} from 'class-validator';

export class {name} {{
  @IsString()
  @IsNotEmpty()
  {field}: string;{rest}
}}
]],
   { name = name_node(1, "Dto"), field = i(2, "name"), rest = i(0) },
})

add("nentity", "TypeORM entity", {
   [[
import {{ Column, CreateDateColumn, Entity, PrimaryGeneratedColumn, UpdateDateColumn }} from 'typeorm';

@Entity('{table}')
export class {name} {{
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  {field}: string;{rest}

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}}
]],
   {
      table = feature_node(1, "table"),
      name = prefilled(2, function()
         return pascal(feature("Entity"))
      end),
      field = i(3, "name"),
      rest = i(0),
   },
})

add("nschema", "Mongoose schema (@nestjs/mongoose)", {
   [[
import {{ Prop, Schema, SchemaFactory }} from '@nestjs/mongoose';
import {{ HydratedDocument }} from 'mongoose';

export type {name}Document = HydratedDocument<{name}>;

@Schema({{ timestamps: true }})
export class {name} {{
  @Prop({{ required: true }})
  {field}: string;{rest}
}}

export const {name}Schema = SchemaFactory.createForClass({name});
]],
   {
      name = prefilled(1, function()
         return pascal(feature("Model"))
      end),
      field = i(2, "name"),
      rest = i(0),
   },
})

-- route handlers ----------------------------------------------------------

local function handler(trig, verb, path, method, args, call)
   add("n" .. trig, "@" .. verb .. "() handler", {
      [[
@{verb}({path})
{method}({args}) {{
  return this.{svc}.{call};
}}
]],
      {
         verb = t(verb),
         path = i(1, path),
         method = i(2, method),
         args = i(3, args),
         svc = prefilled(4, function()
            return camel(feature("")) .. "Service"
         end),
         call = i(5, call),
      },
   })
end

handler("get", "Get", "", "findAll", "", "findAll()")
handler("getid", "Get", "':id'", "findOne", "@Param('id') id: string", "findOne(id)")
handler("post", "Post", "", "create", "@Body() dto: CreateDto", "create(dto)")
handler("put", "Put", "':id'", "replace", "@Param('id') id: string, @Body() dto: UpdateDto", "update(id, dto)")
handler("patch", "Patch", "':id'", "update", "@Param('id') id: string, @Body() dto: UpdateDto", "update(id, dto)")
handler("delete", "Delete", "':id'", "remove", "@Param('id') id: string", "remove(id)")

add("ncrud", "Full CRUD controller (like `nest g resource`)", {
   [[
import {{ Body, Controller, Delete, Get, Param, Patch, Post }} from '@nestjs/common';
import {{ {Svc} }} from './{feat}.service';
import {{ Create{One}Dto }} from './dto/create-{one}.dto';
import {{ Update{One}Dto }} from './dto/update-{one}.dto';

@Controller('{feat}')
export class {name} {{
  constructor(private readonly {svc}: {Svc}) {{}}

  @Post()
  create(@Body() dto: Create{One}Dto) {{
    return this.{svc}.create(dto);
  }}

  @Get()
  findAll() {{
    return this.{svc}.findAll();
  }}

  @Get(':id')
  findOne(@Param('id') id: string) {{
    return this.{svc}.findOne(id);
  }}

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: Update{One}Dto) {{
    return this.{svc}.update(id, dto);
  }}

  @Delete(':id')
  remove(@Param('id') id: string) {{
    return this.{svc}.remove(id);
  }}
}}
]],
   {
      feat = feature_node(1, "users"),
      name = name_node(2, "Controller"),
      Svc = from_feature(1, function(ft)
         return pascal(ft) .. "Service"
      end),
      svc = from_feature(1, function(ft)
         return camel(ft) .. "Service"
      end),
      One = from_feature(1, function(ft)
         return pascal(singular(ft))
      end),
      one = from_feature(1, singular),
   },
})

-- small pieces ------------------------------------------------------------

add("ninject", "constructor(private readonly xService: XService) {}", {
   "constructor(private readonly {svc}: {Svc}) {{}}",
   {
      svc = prefilled(1, function()
         return camel(feature("")) .. "Service"
      end),
      Svc = prefilled(2, function()
         return pascal(feature("")) .. "Service"
      end),
   },
})

add("nrepo", "@InjectRepository(Entity) repository", {
   "@InjectRepository({Entity}) private readonly {repo}: Repository<{Entity}>",
   {
      Entity = prefilled(1, function()
         return pascal(singular(feature("Entity")))
      end),
      repo = prefilled(2, function()
         return camel(singular(feature(""))) .. "Repository"
      end),
   },
})

add("nlogger", "private readonly logger = new Logger(X.name)", {
   "private readonly logger = new Logger({name}.name);",
   { name = name_node(1, "") },
})

add("nthrow", "throw new <Http>Exception()", {
   "throw new {exc}('{msg}');",
   {
      exc = c(1, {
         t("NotFoundException"),
         t("BadRequestException"),
         t("UnauthorizedException"),
         t("ForbiddenException"),
         t("ConflictException"),
         t("InternalServerErrorException"),
      }),
      msg = i(2, "message"),
   },
})

add("nbootstrap", "main.ts bootstrap()", {
   [[
import {{ NestFactory }} from '@nestjs/core';
import {{ ValidationPipe }} from '@nestjs/common';
import {{ AppModule }} from './app.module';

async function bootstrap() {{
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(new ValidationPipe({{ whitelist: true, transform: true }}));
  await app.listen(process.env.PORT ?? {port});
}}
bootstrap();
]],
   { port = i(1, "3000") },
})

-- tests -------------------------------------------------------------------

add("nspec", "Jest spec for a provider/controller", {
   [[
import {{ Test, TestingModule }} from '@nestjs/testing';
import {{ {Class} }} from './{file}';

describe('{Class}', () => {{
  let {inst}: {Class};

  beforeEach(async () => {{
    const module: TestingModule = await Test.createTestingModule({{
      {kind}: [{Class}],
    }}).compile();

    {inst} = module.get<{Class}>({Class});
  }});

  it('should be defined', () => {{
    expect({inst}).toBeDefined();
  }});{rest}
}});
]],
   {
      Class = name_node(1, "Service"),
      file = prefilled(2, function()
         local parts = file_parts()
         return #parts > 0 and table.concat(parts, ".") or "x.service"
      end),
      inst = f(function(args)
         return camel(args[1][1] or "")
      end, { 1 }),
      kind = prefilled(3, function()
         return file_parts()[2] == "controller" and "controllers" or "providers"
      end),
      rest = i(0),
   },
})

add("ne2e", "Jest e2e spec with supertest", {
   [[
import {{ INestApplication }} from '@nestjs/common';
import {{ Test, TestingModule }} from '@nestjs/testing';
import * as request from 'supertest';
import {{ AppModule }} from './../src/app.module';

describe('{name} (e2e)', () => {{
  let app: INestApplication;

  beforeEach(async () => {{
    const moduleFixture: TestingModule = await Test.createTestingModule({{
      imports: [AppModule],
    }}).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  }});

  afterAll(async () => {{
    await app.close();
  }});

  it('/{route} (GET)', () => {{
    return request(app.getHttpServer()).get('/{route}').expect(200);
  }});{rest}
}});
]],
   {
      name = name_node(1, "Controller"),
      -- app.e2e-spec.ts (the scaffolded one) tests `/`, not `/app`.
      route = prefilled(2, function()
         local ft = feature("")
         return ft == "app" and "" or ft
      end),
      rest = i(0),
   },
})

add("ita", "it('…', async () => {})", {
   [[
it('{desc}', async () => {{
  {body}
}});
]],
   { desc = i(1, "should "), body = i(0) },
})

add("bfe", "beforeEach(async () => {})", {
   [[
beforeEach(async () => {{
  {body}
}});
]],
   { body = i(0) },
})

add("afa", "afterAll(async () => {})", {
   [[
afterAll(async () => {{
  {body}
}});
]],
   { body = i(0) },
})

add("nmock", "mock provider for Test.createTestingModule", {
   [[
{{
  provide: {token},
  useValue: {{
    {method}: {mock}.fn(){rest}
  }},
}},
]],
   {
      token = prefilled(1, function()
         return pascal(feature("")) .. "Service"
      end),
      method = i(2, "findAll"),
      -- jest.fn() or vi.fn() depending on the project's runner.
      mock = f(function()
         return require("rvldodo.core.typescript").test_runner() == "vitest" and "vi" or "jest"
      end),
      rest = i(0),
   },
})

return snippets
