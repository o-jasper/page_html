-- All `os.execute` should go through here. Tries to narrow stuff down.
--
-- TODO better if no script is involved in the first place.. Just feeding
-- the strings into the program..

local function find_or(str, list)
   for _, el in ipairs(list) do
      if type(el) == "function" and el(str) or string.find(str, el) then
         return true
      end
   end
end

local perms = require "page_html.util.exec_allowed"

for k,v in pairs(perms) do
   -- Anti-typo-accidental-permissions.
   assert(({whitelist_override=true, blacklist=true, no_print=true,
            required=true, print_matched=true})[k],
      string.format("%s(%s) is not a permissions option", k,type(k)))
   assert(type(v) == "table", "%s of %s is not a table of strings/functions.", v, k)
end

-- Exec, hopefully a tad safer..
return function(str, first, ...)
   local cmd = first and string.format(str, first, ...) or str

   if not find_or(str, perms.whitelist_override or {}) then  -- Careful..
      if find_or(str, perms.blacklist or {}) then
         print("FAILED BLACKLIST", cmd)
         return
      elseif not find_or(str, perms.required) then
         print("FAILED REQUIRED", cmd)
         return
      end
      if find_or(str, perms.print_matched or {}) then
         print("MATCHED", cmd)
      elseif not find_or(str, perms.no_print or {}) then
         print("EXEC", cmd)
      end
   end
   os.execute(cmd)
end
