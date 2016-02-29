return function()
   local fd  = io.open("/tmp/sync_clip")
   local ret = fd:read("*a")
   fd:close()
   return ret
end
