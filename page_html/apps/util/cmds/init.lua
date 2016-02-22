local function r_util(s)
   return require("page_html.apps.util.cmds." .. s)
end

-- setmetatable({}, {__index=function(_, key) return r_util(key) end})
-- maybe not, feels a bit more secure.
return {
   pydoc = r_util "pydoc",
   doc   = r_util "doc",
   man   = r_util "man",
--   bm    = r_util "bookmark",
   vid   = r_util "mpv",
--   go    = r_util "go",
}
