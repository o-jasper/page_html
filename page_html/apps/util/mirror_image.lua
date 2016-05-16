local mpv = require "page_html.apps.util.cmds.mpv"

local mirror_on_userscript, view_it = false, true

-- NOTE/TODO sometimes the server on the other end:
-- * Doesnt use the extension.
-- * Will do an html page instead.
-- * Refuses if wget does it.

local function any_pat(str, list)
   for _, el in ipairs(list) do if string.find(string.lower(str), el) then return true end end
end

local detectors = require "page_html.apps.util.mirror_image_detect"

local function mirror_and_return(info, uri, pref_append, ...)
   -- Direct the mirror page to mirror the uri.
   local mirror_uri, success =
      info.server.pages.history_mirrored:mirror_uri(uri, mirror_on_userscript)

   local ret = {m_uri=mirror_uri, view_it=success and view_it,
                pref_uri = pref_append and (mirror_uri .. pref_append) or nil}
   if success then  -- Got it.
      return ret
   elseif view_it then  -- Don't have it and need to get from the userscript.
      ret.get_it = mirror_on_userscript
      return ret
   end
end

-- TODO need to take a part.
return function(exclude)
   return function(info, uri, ...)
      if exclude and any_pat(uri, exclude) then return end

      for k, fun in pairs(detectors) do
         local new_uri, pref_append = fun(uri)
         if new_uri then
            return mirror_and_return(info, new_uri, pref_append, ...)
         end
      end
   end
end
