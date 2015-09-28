local p = require("page_html.serve.pegasus"):new()

p:add(require "page_html.serve.examples.direct")
p:add(require "page_html.serve.examples.templated")
p:add(require "page_html.serve.examples.basic_dir_explorer")

p:start()
