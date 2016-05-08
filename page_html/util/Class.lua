-- Class base.

local Class = {}

function Class:class_derive(...)
   local NewClass = {}
   for _, el in ipairs{self, ...} do  -- Note: might stuff in some values at the end.
      for k,v in pairs(el) do NewClass[k] = v end
   end
   NewClass.__index = NewClass
   NewClass.__parents = {...}  -- Lets not forget..
   return NewClass
end

function Class:new(new, ...)
   new = setmetatable(new or {}, self)
   new:init(...)
   return new
end

function Class:init(new) end

Class.__name = "Unnamed class"

return Class
