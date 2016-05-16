math.randomseed(1000000*os.time() + math.floor(1000000*os.clock()))

local data_dir = os.getenv("HOME") .. "/.page_html/data/"
local exec = require "page_html.util.exec"

exec([[mkdir -p "%s"]], data_dir)  -- Create if doesn't exist.
local db_file = data_dir .. "main.db"

local file_or_random = require "page_html.util.file_or_random"

local settings = {
   data_dir = data_dir, db_file=db_file,

   dumb_pw = file_or_random(data_dir .. "dumb_pw")
   -- rpc_sql_enabled = true, -- To enable that.(listview)
}

local function inp()
   local ret = {}
   for k,v in pairs(settings) do ret[k] = v end
   return ret
end

local p = require("page_html.serve.pegasus"):new{port=(tonumber(arg[1]) or 9090)}

--p:add(require("page_html.apps.DirList"):new())
p:add(require("page_html.apps.DirList2"):new())
p:add(require("page_html.apps.history"):new(inp()))

p:add(require("page_html.apps.bookmarks"):new(inp()))
p:add(require("page_html.apps.comments"):new(inp()))

p:add(require("page_html.apps.util"):new(inp()))

p:add(require("page_html.apps.userscripts"):new(inp()))

p:start()
