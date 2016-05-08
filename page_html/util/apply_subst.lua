return function(str, subst, max_tries, matcher)
   assert(type(str) == "string", string.format("Subst not string instead: %s", str))
   local fail_n = 0
   local function fun(key, args)
      local got = subst[key]
      if type(got) == "function" then got = got(subst, args) end

      if got == nil then fail_n = fail_n + 1 end
      return got
   end

   local n, k = 1, 0
   while n > fail_n and k < (max_tries or 256) do  -- More items substituted than failed.
      fail_n = 0
      str, n = string.gsub(str, matcher or "{%%([%w_./]+)[%s]*([^}]*)}", fun)
      k = k + 1
   end
   return str
end
