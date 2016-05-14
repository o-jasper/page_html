local function find_or(str, list)
   for _, el in ipairs(list) do
      if string.find(str, el) then return true end
   end
end

local function probably_safe(str)
   if string.find(str, "^mkdir[%s]") then  -- `mkdir` this particular form.
      local only = {[[^mkdir %-p "[%w_+-./:]+"$]], [[^mkdir "[%w_+-./:]+"$]]}
      if not find_or(str, only) then
         return false 
      end  -- Never `rm`
   elseif find_or(str, {"^rm[%s]", "[$()]"}) then
      return false
   end


   return find_or(str, {"^echo$", "^echo[%s][%s%w]*$"})
end

-- Exec, hopefully a tad safer..
return function(str, ...)
   local cmd = string.format(str, ...)
   local c = probably_safe(cmd)
   if c == false then  -- Don't run this.
      print("AVOIDED", cmd)
      return
   elseif c ~= true then  -- Okey enough to not mention.
      print("EXEC", cmd)
   end
   os.execute(cmd)
end
