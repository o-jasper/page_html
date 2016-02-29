local function r_util(s)
   return require("page_html.apps.util.cmds." .. s)
end

-- setmetatable({}, {__index=function(_, key) return r_util(key) end})
-- maybe not, feels a bit more secure.
local cmds = {
   pydoc = true, doc = true, man = true, fclip = true,
--   go
   vid   = r_util "mpv",
}

local ret = {}
for k,v in pairs(cmds) do
   if v == true then ret[k] = r_util(k) else ret[k] = v end
end

return ret
