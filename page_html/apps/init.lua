local p = require("page_html.serve.pegasus"):new()

p:add(require("page_html.apps.DirList"):new())

p:start()
