return function(str, subst)
   assert(type(str) == "string")
   local fail_n = 0
   local function fun(key, args)
      local got = subst[key]
      if type(got) == "function" then got = got(args) end
      if got ~= nil then
         return got
      else
         fail_n = fail_n + 1
      end
   end

   local n, k = 1, 0
   while n > fail_n and k < 256 do  -- More items substituted than failed.
      fail_n = 0
      str, n = string.gsub(str, "{%%([_.:/%w%%]+)|?([_.,%s:/%w%%]*)}", fun)
      k = k + 1
   end
   return str
end
