local This = require("page_html.util.Class"):class_derive{
   name="util", __name="page_html.apps.util" }

This.description =  "Set of functions for javascript RPC. does not have page.(currently)"

function This:rpc_js()
   -- Just cmds at the moment.
   local funs = {}
   for k,v in pairs(require "page_html.apps.util.cmds") do
      funs["." ..  k] = function(info, ...)
         if self.disable_dumb_pw or info.dumb_pw == self.dumb_pw then
            info.server = self.server  -- Sounds wrong.
            return v(info, ...)
         else
            print("Failure to match pw! Util call:", k)
         end
      end
   end
   return funs
end

return This
