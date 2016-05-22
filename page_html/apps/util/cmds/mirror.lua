local mirror_image = require "page_html.apps.util.mirror_image"

local view_it = true

return function(info, uri, ...)
   local ret = mirror_image{}(info, uri, ...)
   if ret then return ret end
   -- Mirror it as a page.
   local mirrorer = info.server.pages.history_mirrored
   local cmd_name = string.match(info.extra or "", [[;tor=true;]]) and "tor_wget_kr"
   local mirror_uri = mirrorer:mirror_uri_kr(uri, cmd_name)

   return { m_uri=mirror_uri, view_it=view_it }
end
