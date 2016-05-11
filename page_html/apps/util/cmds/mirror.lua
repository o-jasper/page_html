local mirror_image = require "page_html.apps.util.mirror_image"

local mirror_on_userscript, view_it = false, true

return function(server, uri, ...)
   local ret = mirror_image{}(server, uri, ...)
   if ret then return ret end
   -- Mirror it as a page.
   local mirrorer = server.pages.history_mirrored
   local mirror_uri = mirrorer:mirror_uri_kr(uri, mirror_on_userscript)

   return { m_uri=mirror_uri, view_it=view_it }
end
