return function(str, subst)
   local fail_n = 0
   local function fun(key)
      if subst[key] then
         return subst[key]
      else
         fail_n = fail_n + 1
      end
   end

   local n, k = 1, 0
   while n > fail_n and k < 256 do  -- More items substituted than failed.
      fail_n = 0
      str, n = string.gsub(str, "{%%([_.:/%w%%]+)}", fun)
      k = k + 1
   end
   return str
end
