--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO some kind of "sorted list type" would work a lot better...

local Public = {}

local function newlist(fun, context, entry)
   if fun.newlist then
      local ret = fun:newlist(context, entry) or {}
      assert(type(ret) == "table")
      return ret
   else  -- Defaults to just creating one and stuffing the context on.
      entry.context = context
      return {fun:new( entry )}
   end
end

-- Only keep if sufficient priority.
local function info_on(entry, context, info_ons, into)
   local thresh = context.thresh
   into = into or {}
   for key, fun in pairs(info_ons or context:config().info_ons) do
      for _, el in pairs(newlist(fun, context, entry)) do
         -- Do immediate selection.
         if not thresh then
            table.insert(into, el)  
         elseif el:priority() > thresh then
            table.insert(into, el)  
         end
      end
   end
   return into
end
Public.entry_on = info_on

local function fun_on_each(fun)
   return function (list, ...)
      local ret = {}
      for _, entry in pairs(list) do
         for _, el in pairs(fun(entry, ...)) do
            table.insert(ret, el)
         end
      end
      return ret
   end
end

Public.list = fun_on_each(info_on)  -- Info on list of entries.

local function compare(a,b) return a:priority() > b:priority() end

-- Pick N highest priorities. Note: obviously not very optimized..
function Public.pick_highest_priorities(info_on_list, n, choosing_fraction)
   local n, top = n or 1, {}
   -- List much longer than number to pick -> faster to sort the smaller list often.
   if n < #info_on_list / choosing_fraction then
      local thresh = 0
      for _, got in pairs(info_on_list) do
         if #top < n then  -- Not enough yet anyway.
            table.insert(top, priority)
            if #top == n then   -- Hit the number, need a threshhold.
               table.sort(top, compare)
               thresh = top[#top]:priority()
            end
         elseif got:priority() > thresh then
            table.remove(top)  -- Last is least.
            table.insert(top, got)
            table.sort(top, compare)
         end
      end
   else  -- Otherwise: sort the whole thing..
      table.sort(info, compare)  -- Just sort whole thing and insert ontop.
      for i = 1, n do table.insert(top, info_on_list[i]) end
   end
   return top
end

return Public
