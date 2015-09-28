local insert = table.insert

local function list(next, first)
   local k,v = next(first)
   local ret = {}
   while k do
      insert(ret, v)
      k,v = next(k)
   end
   insert(ret, v)
   return ret
end

return list
