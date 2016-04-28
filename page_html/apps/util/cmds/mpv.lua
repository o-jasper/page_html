local default_geometry = "100%x100%"

-- TODO video-finished callback..

function mpv_cmd(uri, geometry)
   local use_uri = string.match(uri, "^[^&]+") or uri
   if geometry == "fullscreen" then
      return string.format("mpv --force-window --fs \"%s\" &", use_uri)
   else
      return string.format("mpv --force-window --geometry=%s \"%s\" &",
                          geometry or default_geometry, use_uri)
   end
end

return function(_, uri, ...)
   local cmd = mpv_cmd(uri, ...)
   print("----RUN:", cmd)
   os.execute(cmd)
end
