-- Simple page(potentially substition and asset use.

local apply_subst = require "page_html.util.apply_subst"

local This = {}
for k,v in pairs(require "page_html.Assets") do This[k] = v end
This.__index = This

function This:output(args)
   local str = self.where and self:load(self[1]) or self[1]

   if self.repl == true then
      local function index(_,k) return args[k] or self[k] end
      return apply_subset(str, setmetatable({}, {__index= index}))
   else
      return str
   end
end

return This
