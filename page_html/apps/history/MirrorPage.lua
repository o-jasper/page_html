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
   pattern = [[Excepting outside assets, this a local mirror:{%is_top}<br><br>{%mirror}]],
   is_top = [[<span style="color:gray">(top of dir)</span>]],
}

function This:have_mirror_fd(uri)
   local file = self.dir .. uri
   if lfs.attributes(file, "mode") == "directory" then
      return io.open(file .. "/index.html"), "directory"
   else
      local fd, msg, code = io.open(file)
      return (fd and fd:read(0) and fd), msg, code  -- LOGIC!
   end
end

function This:have_mirror(uri)
   local fd = self:have_mirror_fd(uri)
   if fd then
      fd:close()
      return true
   end
end

function This:link_part(el)
   local mirror_page = self.server.pages.history_mirrored
   if mirror_page and mirror_page:have_mirror(el.uri) then
      return apply_subst([[<span class="local_version">(<a class="local_version_href" href="{%local_href}">local</a>)</span>]], 
         { local_href = "/history_mirrored/" .. el.uri })
   else
      return " "
   end
end

function This:output(args)
   local fd, msg, code = self:have_mirror_fd(args.rest_path)

   local mm = self.mirror_msg
   if fd then
      local repl = {
         is_top=(code =="directory" and mm.is_top or ""),
         mirror=fd:read("*a"),
      }
      return apply_subst(mm.pattern, repl)
   else
      return string.format([[Couldnt read; %q <span style="color:gray">(%s)</span>]],
         msg, code)
   end
end

return This
