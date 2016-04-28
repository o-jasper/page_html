local data_dir = os.getenv("HOME") .. "/.page_html/data/"

os.execute("mkdir -p " .. data_dir)  -- Create if doesn't exist.

local p = require("page_html.serve.pegasus"):new()

--p:add(require("page_html.apps.DirList"):new())
p:add(require("page_html.apps.DirList2"):new())
p:add(require("page_html.apps.history"):new{data_dir = data_dir})

p:add(require("page_html.apps.bookmarks"):new{data_dir = data_dir})
p:add(require("page_html.apps.comments"):new{data_dir = data_dir})

p:add(require("page_html.apps.util"):new())

p:start()
