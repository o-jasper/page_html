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
   pattern = [[Other than outside assets, this a {%local_mirror}:{%is_top}<br>
{%from_time}, size {%gist_size}
<hr>{%mirror}]],
   fail_pattern = [[Couldnt read; {%msg} <span style="color:gray">({%code})</span>
<br>{%spell_it}]],
   is_top = [[<span style="color:gray">(top of dir)</span>]],
}

function This:have_mirror_fd(uri)
   local file = self.dir .. uri
   if lfs.attributes(file, "mode") == "directory" then
      return io.open(file .. "/index.html"), "directory", nil, file
   else
      local fd, msg, code = io.open(file)
      return (fd and fd:read(0) and fd), msg, code, file  -- LOGIC!
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

local gist = require("page_html.util.text.number").gist

This.can_link_direct_file = false

function This:output(args)
   local fd, msg, code, file = self:have_mirror_fd(args.rest_path)
   local attrs = lfs.attributes(file)

   local repl = {}
   for k,v in pairs(attrs or {}) do repl[k] = v end

   function repl.spell_it ()
      local ret = {"<table>"}
      for k,v in pairs(attrs or {}) do
         table.insert(ret, string.format("<tr><td>%s</td><td>%s</td></tr>", k,v))
      end
      return table.concat(ret,"\n") .. "</table>"
   end

   repl.from_time = function() return os.date("%c", attrs.modification) end
   repl.gist_size = function() return gist(attrs.size) end

   repl.local_mirror = can_link_direct_file and [[<a href="{%mirror_href}">local mirror</a>]]
      or "local mirror"
   repl.mirror_href  = "file:/" .. file

   local mm = self.mirror_msg
   if fd then
      for k,v in pairs{
         is_top=(code =="directory" and mm.is_top or ""),
         mirror=fd:read("*a"),
      } do repl[k] = v end
      return apply_subst(mm.pattern, repl)
   else
      for k,v in pairs{
         msg = msg, code = code or "(nil)",
      } do repl[k] = v end
      return apply_subst(mm.fail_pattern, repl)
   end
end

return This
