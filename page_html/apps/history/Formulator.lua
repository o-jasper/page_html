--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Formulator = require "Searcher.Formulator"
local This = require("page_html.util.Class"):class_derive(
   Formulator, { __name="page_html.apps.history.Formulator"})

This.values = {
   table_name = "history",
   
   idname = "id",
   row_names = {"id", "uri", "title", "last", "visits"},
   
   time = "last", timemul = 1,
   order_by = "last",
   textlike = {"uri", "title"},

   textable   = {"title"},
   comparable = {"last"},
   timable    = {"last"},

   string_els = {"uri", "title"},
   int_els = {"id", "last", "visits"},
}

local mf = {}
This.match_funs = mf
for k,v in pairs(Formulator.match_funs or {}) do mf[k] = v end

This.matchable = {"limit:", "order:", "sort:", "orderby:"}

require("Searcher.Formulator.auto_add")(This.values, mf, This.matchable)

return This
