return function(file, n)
   local str, fd = "", io.open(file)
   if fd then
      str = fd:read("*a")
      fd:close()
   else
      local from = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      local k = math.random(#from)   -- Make it a bit more messy.
      fd = io.open("/dev/random")
      for _ = 1,(n or 22) do
         local j = (string.byte(fd:read(1)) + k)%(#from)  -- Not quite right...
         str = str .. string.sub(from, j, j)
      end
      fd:close()

      local fd = io.open(file, "w")
      fd:write(str)
   end
   return str
end
