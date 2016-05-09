local function find_or(str, list)
   for _, el in ipairs(list) do
      if string.find(str, el) then return true end
   end
end

local function probably_safe(str)
   if string.find(str, "^mkdir[%s]") then  -- mkdir this particular form.
      if not find_or(str, {[[^mkdir %-p "[^"%{%};]+"$]], [[^mkdir "[^"%{%};]+"$]]})then 
         return false 
      end
   end
   return find_or(str, {"^echo$", "^echo[%s][%s%w]*$"})
end

-- Exec, hopefully a tad safer..
return function(str, ...)
   local cmd = string.format(str, ...)
   local c = probably_safe(cmd)
   if c == false then
      print("AVOIDED", cmd)
      return
   elseif c ~= true then
      print("EXEC", cmd)
   end
   local fd = io.popen(cmd)
   return fd:read("*a")
end
