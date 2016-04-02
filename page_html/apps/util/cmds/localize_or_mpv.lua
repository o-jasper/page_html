local mpv = require "page_html.apps.util.cmds.mpv"

local mirror_on_userscript, view_it = false, true

-- NOTE/TODO sometimes the server on the other end:
-- * Doesnt use the extension.
-- * Will do an html page instead.
-- * Refuses if wget does it.

-- Defaultly via a page with the asset on it.
local indirect_pats = {"[^/]+[.]png$", "[^/]+[.]svg", "[^/]+[.]jpe?g"}
-- Defaultly directly, let the browser figure it out.
local direct_pats = {"[^/]+[.]pdf$", "[^/]+[.]ps$"}

local find = string.find
local function any_pat(str, list)
   for _, el in ipairs(list) do if find(string.lower(str), el) then return true end end
end

return function(server, uri, ...)
   local m = any_pat(uri, indirect_pats)
   local md = any_pat(uri, direct_pats)
   if m or md then
      -- Direct the mirror page to mirror the uri.
      local mirror_uri, success =
         server.pages.history_mirrored:mirror_uri(uri, mirror_on_userscript)

      if success then  -- Got it.
         return {m_uri=mirror_uri, view_it=success and view_it,
                 pref_uri = (m and (mirror_uri .. "/html/")) or nil
         }
      elseif view_it then  -- Don't have it and need to get from the userscript.
         return { m_uri=mirror_uri, get_it=mirror_on_userscript, view_it=view_it }
      end
   else  -- Straight video.
      mpv(nil, uri, ...)  -- Shouldnt care about server.
   end
end
