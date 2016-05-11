local mirror_image = require "page_html.apps.util.mirror_image"

local mirror_on_userscript, view_it = false, true

return function(server, uri, ...)
   local ret = mirror_image{}(server, uri, ...)
   if ret then return ret end
   -- Mirror it as a page.
   local mirror_uri = server.pages.history_mirrored:mirror_uri(uri, mirror_on_userscript)
   
   return { m_uri=mirror_uri, view_it=view_it }
end
