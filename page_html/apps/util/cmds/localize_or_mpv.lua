local find = string.find

local mpv = require "page_html.apps.util.cmds.mpv"

local mirror_on_userscript, view_it = false, true

return function(server, uri, ...)
   local m = find(string.lower(uri), "[^/]+[.]jpe?g$") or
      find(string.lower(uri), "[^/]+[.]png$") or
      find(string.lower(uri), "[^/]+[.]svg$")
   local md =
      find(string.lower(uri), "[^/]+[.]pdf$") or
      find(string.lower(uri), "[^/]+[.]ps$")
   if m or md then
      -- Direct the mirror page to mirror the uri.
      local mirror_uri, success =
         server.pages.history_mirrored:mirror_uri(uri, mirror_on_userscript)
      print(mirror_uri)
      if success then  -- Got it.
         return {m_uri=mirror_uri, view_it=success and view_it,
                 pref_uri = (m and (mirror_uri .. "/html/")) or nil
         }
      elseif view_it then  -- Don't have it and need to get from the userscript.
         return { get_it=mirror_on_userscript, view_it=view_it }
      end
   else  -- Straight video.
      mpv(nil, uri, ...)  -- Shouldnt care about server.
   end
end
