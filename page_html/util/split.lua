local find = string.find
local function split(str, by)
   by = by or " "
   local function next(prev, str)
      str = str or prev
      local i = find(str, by)
      if i then
         return string.sub(str, i + 1), string.sub(str, 1, i-1)
      else
         return nil, str
      end
   end
   return next, str
end

return split
