local This = {}
This.__index = This

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function This:init() assert(type(self.dir) == "string") end

local lfs = require "lfs"

local apply_subst = require "page_html.util.apply_subst"
This.mirror_msg = {
      pattern = [[Excepting outside assets, this a local mirror:{%is_top}<br><br>]],
      is_top = [[<span style="color:gray">(top of dir)</span>]],
}

function This:output(args)
   local mm = self.mirror_msg

   local function finally(ret, data)
      -- Can we indicate that no scripts are to be ran?
      return apply_subst(mm.pattern, data) .. ret
   end

   local file = self.dir .. args.rest_path
   if lfs.attributes(file, "mode") == "directory" then
      local fd = io.open(file .. "/index.html")
      if fd then
         local ret = fd:read("*a")
         fd:close()
         return finally(ret, {is_top=mm.is_top})
      else
         return "Is a directory with no index.html file. TODO redirect to directory view?"
      end
   else
      local function report(...)
         return string.format([[%s; %q <span style="color:gray">(%s)</span>]], ...)
      end
         
      local fd, msg, code = io.open(file)
      if fd then
         local ret, msg, code = fd:read("*a")
         if ret then
            return finally(ret, {is_top=" "})
         else
            return report("Couldnt read", msg, code)
         end
      else
         return report("Couldnt open", msg, code)
      end
   end
end

return This
