local function tab(next, first)
   local k,v = next(first)
   local ret = {}
   while k do
      ret[k] = v
      k,v = next(k)
   end
   return ret
end

return tab
