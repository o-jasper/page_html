local Formulator = require "Searcher.Formulator"

local This = {}

for k,v in pairs(Formulator) do This[k] = v end

This.__index = This

This.values = {
   table_name = "files",
   
   idname = "id",
   row_names = {"id", "dir", "file", "mode",
                "size", "access", "modification"},
   
   time = "modification", timemul = 1000,
   order_by = "modification",
   textlike = {"dir", "file"},

   textable   = {"dir", "file", "mode"},
   comparable = {"size", "access", "modification"},
   timable    = {"access", "modification"},

   string_els = {"dir", "file", "mode"},
   int_els = {"id", "size", "access", "modification"},
}

function This:dir_eq(dir)
   return self:equal("dir", dir)
end
function This:file_eq(file)
   return self:equal("file", file)
end

-- TODO one-element in dir, show direct?

local mf = {}
This.match_funs = mf
for k,v in pairs(Formulator.match_funs or {}) do mf[k] = v end

This.matchable = {"limit:", "order:", "sort:", "orderby:"}

require("Searcher.Formulator.auto_add")(This.values, mf, This.matchable)

-- TODO add onto `dir=` goes to specific directory.

return This
