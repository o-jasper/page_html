local find = string.find

local mpv = require "page_html.apps.util.cmds.mpv"

return function(server, uri, ...)
   local m = find(string.lower(uri), "[^/]+[.]jpe?g$") or
      find(string.lower(uri), "[^/]+[.]png$") or
      find(string.lower(uri), "[^/]+[.]svg$")
   local md =
      find(string.lower(uri), "[^/]+[.]pdf$") or
      find(string.lower(uri), "[^/]+[.]ps$")
   if m or md then
      -- Direct the mirror page to mirror the uri.
      local mirror_uri, success = server.pages.history_mirrored:mirror_uri(uri)
      print(m, md)
      return {m_uri=mirror_uri, success=success,
              pref_uri = (m and (mirror_uri .. "/html/")) or nil
      }
   else
      mpv(nil, uri, ...)  -- Shouldnt care about server.
   end
end
