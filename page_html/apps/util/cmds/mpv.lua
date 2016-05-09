local default_geometry = "100%x100%"

-- TODO video-finished callback..
local uri_check = [[^[%a][%w-+.]*://^[^%s#?"';{}()]+[?#]?[^%s"';{}()]$]]

function mpv_cmd(uri, geometry)
   if not string.find(uri, uri_check) then return "echo" end

   -- Note if this works tell mpv about it?
   local yc = string.match(
      uri,
      "^https?://www[.]youtube[.]com/attribution_link%?a=.+watch%%3Fv%%3D(.+)%%26")

   -- Tbh if i could send attribution links.. should i leave it defaultly on?
   if yc then
      uri = "https://www.youtube.com/watch?v=" .. yc
   end

   local use_uri = string.match(uri, "^[^&]+") or uri
   if geometry == "fullscreen" then
      return string.format("mpv --force-window --fs \"%s\" &", use_uri)
   else
      return string.format("mpv --force-window --geometry=%s \"%s\" &",
                          geometry or default_geometry, use_uri)
   end
end

local exec = require "page_html.util.exec"
return function(_, uri, ...)
   exec(mpv_cmd(uri, ...))
end
