local Public = {}

Public.name = "util"

function Public:rpc_js()
   -- Just cmds at the moment.
   local funs = {}
   for k,v in pairs(require "page_html.apps.util.cmds") do funs["." ..  k] = v end
   return funs
end

return Public
