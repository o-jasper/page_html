
local function any_pat(str, list)
   for _, el in ipairs(list) do if string.find(string.lower(str), el) then return true end end
end

-- Defaultly via a page with the asset in it.
local indirect_pats = {"[^/]+[.]png$", "[^/]+[.]svg", "[^/]+[.]jpe?g", "[^/][.]gif"}
-- Defaultly directly, let the browser figure it out.
local direct_pats = {"[^/]+[.]pdf$", "[^/]+[.]ps$"}

return function(uri)
   if any_pat(uri, indirect_pats) then
      return uri, "/html/"
   elseif any_pat(uri, direct_pats) then
      return uri
   end
end
