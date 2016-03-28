local This = {}
This.__index = This

function This:new(new)
   new = setmetatable(new or {}, This)
   new:init()
   return new
end

function This:init() end

This.name = "util"

function This:rpc_js()
   -- Just cmds at the moment.
   local funs = {}
   for k,v in pairs(require "page_html.apps.util.cmds") do
      funs["." ..  k] = function(...) return v(self.server, ...) end
   end
   return funs
end

return This
