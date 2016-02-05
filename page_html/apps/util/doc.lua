-- Some of the commented-outs should be caught by a pattern.
local dict = {
--lua     = "file:///usr/share/doc/lua/manual.html",
   py      = "file:///usr/share/doc/python/html/index.html",
--python  = "file:///usr/share/doc/python/html/index.html",
   pylib   = "file:///usr/share/doc/python/html/library/index.html",
   pylang  = "file:///usr/share/doc/python/html/reference/index.html",
   polipo  = "file:///usr/share/polipo/www/doc/index.html",
}

local otherwise_patterns = {
   "/usr/share/doc/%s/index.html",
   "/usr/share/doc/%s/ref.html",
   "/usr/share/doc/%s/reference.html",
   "/usr/share/doc/%s/manual.html",

   "/usr/share/doc/%s/html/index.html",
   "/usr/share/doc/%s/html/ref.html",
   "/usr/share/doc/%s/html/reference.html",
   "/usr/share/doc/%s/html/manual.html",

   "/usr/share/gtk-doc/html/%s/index.html",

-- NOTE: links aren't correct in there :/
   "/usr/share/doc/arch-wiki/html/en/%s.html",
}

local function find_otherwise(query)
   -- It is tad limited!
   for _, pat in ipairs(otherwise_patterns) do
      local fd = io.open(string.format(pat, query))
      if fd then fd:close() return "file://" .. string.format(pat, query) end
   end
end

return function(query)
   return dict[query] or find_otherwise(query) or ""
end
