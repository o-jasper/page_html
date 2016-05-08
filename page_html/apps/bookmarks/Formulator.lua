--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Formulator = require "Searcher.Formulator"
local This = require("page_html.util.Class"):class_derive(Formulator)

This.values = {
   table_name = "bookmarks",
   
   idname = "id",
   row_names = {"id", "uri", "title", "text", "quote", "time","x","y"},
   
   time = "time", timemul = 1,
   order_by = "time",
   textlike = {"uri", "title", "text", "quote"},

   textable   = {"title", "text", "quote"},
   comparable = {"time", "x", "y"},
   timable    = {"time"},

   string_els = {"uri", "title", "text", "quote"},
   int_els = {"time", "x","y"},

   tags = { tags = "bookmark_tags" }
}

local mf = {}
This.match_funs = mf
for k,v in pairs(Formulator.match_funs or {}) do mf[k] = v end

This.matchable = {"limit:", "order:", "sort:", "orderby:"}

require("Searcher.Formulator.auto_add")(This.values, mf, This.matchable)

return This
