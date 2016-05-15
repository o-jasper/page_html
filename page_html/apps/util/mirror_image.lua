local mpv = require "page_html.apps.util.cmds.mpv"

local mirror_on_userscript, view_it = false, true

-- NOTE/TODO sometimes the server on the other end:
-- * Doesnt use the extension.
-- * Will do an html page instead.
-- * Refuses if wget does it.

-- Defaultly via a page with the asset in it.
local indirect_pats = {"[^/]+[.]png$", "[^/]+[.]svg", "[^/]+[.]jpe?g", "[^/][.]gif"}
-- Defaultly directly, let the browser figure it out.
local direct_pats = {"[^/]+[.]pdf$", "[^/]+[.]ps$"}

local find = string.find
local function any_pat(str, list)
   for _, el in ipairs(list) do if find(string.lower(str), el) then return true end end
end

local detectors = require "page_html.apps.util.mirror_image_detect"

-- TODO need to take a part.
return function(exclude)
   return function(server, uri, ...)
      if exclude and any_pat(uri, exclude) then return end

      local yes = any_pat(uri, indirect_pats) or any_pat(uri, direct_pats)
      if not yes then
         for k, fun in pairs(detectors) do
            local new_uri = fun(uri)
            if new_uri then
               yes = true
               uri = new_uri
               break
            end
         end
      end

      if yes then
         -- Direct the mirror page to mirror the uri.
         local mirror_uri, success =
            server.pages.history_mirrored:mirror_uri(uri, mirror_on_userscript)

         local ret = {m_uri=mirror_uri, view_it=success and view_it,
                      pref_uri = (m and (mirror_uri .. "/html/")) or nil}
         if success then  -- Got it.
            return ret
         elseif view_it then  -- Don't have it and need to get from the userscript.
            ret.get_it = mirror_on_userscript
            return ret
         end
      end
   end
end
