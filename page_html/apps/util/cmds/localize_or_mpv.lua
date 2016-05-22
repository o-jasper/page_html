local mpv = require "page_html.apps.util.cmds.mpv"
local mirror_image = require "page_html.apps.util.mirror_image"

local localizers = require "page_html.apps.util.cmds.localizers"

return function(info, uri, ...)
   local ret = mirror_image{"[^/][.]gif"}(info, uri, ...)
   if ret then return ret end

   for _,v in pairs(localizers) do  -- Use one of the localizers instead.
      local got = {v(info, uri, ...)}
      if #got > 0 then return unpack(got) end
   end
   -- Assume it is a video.
   mpv(nil, uri, ...)
end
