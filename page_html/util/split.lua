local find = string.find

-- Tokenizes string splitting on pattern.
local function split(str, pattern, plain)
   pattern = pattern or " "
   local function next(prev, str)
      str = str or prev
      local i = find(str, pattern, 1, plain)
      if i then
         return string.sub(str, i + 1), string.sub(str, 1, i-1)
      else
         return nil, str
      end
   end
   return next, str
end

return split
