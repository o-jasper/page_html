local p = require("page_html.serve.pegasus"):new()

--p:add(require("page_html.apps.DirList"):new())
p:add(require("page_html.apps.DirList2"):new())
p:add(require("page_html.apps.history"):new())

p:add(require("page_html.apps.bookmarks"):new())
p:add(require("page_html.apps.comments"):new())

p:add(require("page_html.apps.util"))

p:start()
