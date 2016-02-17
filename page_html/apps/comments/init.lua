--  Copyright (C) 15-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ThreadView = require "page_html.ThreadView"
local Bookmarks = require "page_html.apps.bookmarks"

local This = {}
-- Derive from listview.
for k,v in pairs(ThreadView) do This[k] = v end
This.__index = This

This.name = "comments"

This.Formulator = require "page_html.apps.bookmarks.Formulator"
This.Db         = require "page_html.apps.bookmarks.Bookmarks"

This.where      = {"page_html/apps/comments/",
                   "page_html/apps/bookmarks/", "page_html/ListView/", "page_html/"}
This.assets_arg = {where = This.where}

-- TODO absolute..
This.data_dir = "/home/jasper/iso/newiso/server/althist/data/"
This.db_file  = This.data_dir .. "history.db"

This.table_wid = 4

This.pats = {}
for k,v in pairs(Bookmarks.pats)  do This[k] = v end
for k,v in pairs(ThreadView.pats) do This[k] = v end

function This:el_repl(el, state)
   return Bookmarks._el_repl(self, el, state, ThreadView.el_repl(self, el, state))
end

return This
