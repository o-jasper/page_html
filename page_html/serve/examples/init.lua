local p

if arg then
   local which = (not arg and "luvit") or arg[1] or "pegasus"
   print(which)
   p = require("page_html.serve." .. which):new()
else
   local path = os.getenv("HOME") .. "/.lualibs/"
   package.path = package.path .. ";" .. path .. "?.lua;" .. path .. "?/init.lua"
   print("luvit")
   print(package.path)
   local http = require "http"
   p = require("page_html.serve.luvit")(http):new()
end

p:add(require "page_html.serve.examples.direct")
p:add(require "page_html.serve.examples.templated")
p:add(require "page_html.serve.examples.basic_dir_explorer")
p:add(require("page_html.SimplePage"):new{name="simple", "supersimplepage"})

p:start()
