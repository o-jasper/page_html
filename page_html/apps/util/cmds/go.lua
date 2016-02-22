local tmpdir = "/tmp/man/"

os.execute("mkdir -p " .. tmpdir)

local defs = require "page_html.apps.util.cmds"

return function(query)
   local before, after = string.match(query, "^([^%s]+)[%s](.+)&")

   return defs[before](after)
end
