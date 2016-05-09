local tmpdir = "/tmp/man/"
require("page_html.util.exec")([[mkdir -p "%s"]], tmpdir)

local defs = require "page_html.apps.util.cmds"

return function(_, query)
   local before, after = string.match(query, "^([^%s]+)[%s](.+)&")

   return defs[before](after)
end
