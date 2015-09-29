-- To be specific, maximum argument counts.
-- NOTE: this implies these functions need to be secure.(_if_ exposed to outside world)
local default_allow_direct = { 
   like = 2, not_like = 2, text_like = 2, text_sw = 2,
   equal = 2, lt = 2, gt = 2, after = 2, before = 2,
   auto_by = 0,
   limit = 2,
 }

local function search(sql, Formulator, allow_direct)
   allow_direct = allow_direct or default_allow_direct

   return function(search_term, info)  -- This intended for rpc input.
      local form = Formulator:new()
      form:search_str(search_term)  --TODO .. listify the search term.

      for method, args in pairs(info.direct or {}) do
         local allow = allow_direct[method or "dont"]
         if allow and type(method == "string") and type(args) == "table" then
            while #args > allow do table.remove(args) end  -- Enforce maximum.
            form[method](form, unpack(args))
         end
      end

      form:finish()
      return sql:exec(form:sql_pattern(), unpack(form:sql_values()))
   end
end

return search
