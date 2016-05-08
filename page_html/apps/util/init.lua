local This = require("page_html.util.Class"):class_derive{
   name="util", __name="page_html.apps.util" }

function This:rpc_js()
   -- Just cmds at the moment.
   local funs = {}
   for k,v in pairs(require "page_html.apps.util.cmds") do
      funs["." ..  k] = function(...) return v(self.server, ...) end
   end
   return funs
end

return This
