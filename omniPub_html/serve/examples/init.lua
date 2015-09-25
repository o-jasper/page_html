local p = require("omniPub_html.serve.pegasus"):new()

p:add(require "omniPub_html.serve.examples.direct")
p:add(require "omniPub_html.serve.examples.templated")
p:add(require "omniPub_html.serve.examples.basic_dir_explorer")

p:start()
