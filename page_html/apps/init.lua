local data_dir = os.getenv("HOME") .. "/.page_html/data/"

os.execute("mkdir -p " .. data_dir)  -- Create if doesn't exist.
local db_file = data_dir .. "main.db"
local function inp()
   return {data_dir = data_dir, db_file=db_file}
end

local p = require("page_html.serve.pegasus"):new{port=(tonumber(arg[1]) or 9090)}

--p:add(require("page_html.apps.DirList"):new())
p:add(require("page_html.apps.DirList2"):new())
p:add(require("page_html.apps.history"):new(inp()))

p:add(require("page_html.apps.bookmarks"):new(inp()))
p:add(require("page_html.apps.comments"):new(inp()))

p:add(require("page_html.apps.util"):new())

p:start()
