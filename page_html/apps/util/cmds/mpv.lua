local default_geometry = "100%x100%"

-- TODO video-finished callback..

function mpv_cmd(uri, geometry)
   if geometry == "fullscreen" then
      return string.format("mpv --force-window --fs %s &", uri)
   else
      return string.format("mpv --force-window --geometry=%s %s &",
                          geometry or default_geometry, uri)
   end
end

return function(...)
   local cmd = mpv_cmd(...)
   print("----RUN:", cmd)
   os.execute(cmd)
end
