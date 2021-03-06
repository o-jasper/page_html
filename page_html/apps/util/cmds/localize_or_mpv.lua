local mpv = require "page_html.apps.util.cmds.mpv"
local mirror_image = require "page_html.apps.util.mirror_image"

return function(info, uri, ...)
   local ret = mirror_image{"[^/][.]gif"}(info, uri, ...)
   if ret then return ret end
   -- Assume it is a video.
   mpv(nil, uri, ...)
end
