--  Copyright (C) 15-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ListView = require "page_html.ListView"

local This = {}
-- Derive from listview.
for k,v in pairs(ListView) do This[k] = v end
This.__index = This

This.name = "bookmarks"

This.Formulator = require "page_html.apps.bookmarks.Formulator"
This.Db         = require "page_html.apps.bookmarks.Bookmarks"

This.where      = {"page_html/apps/bookmarks/", "page_html/ListView/", "page_html/"}
This.assets_arg = {where = This.where}

-- TODO absolute..
This.data_dir = "/home/jasper/iso/newiso/server/althist/data/"
This.db_file  = This.data_dir .. "history.db"

This.table_wid = 4

-- TODO extend the alt-list with position-percentages.
-- TODO also want tags to show.
function This:el_repl(el, state)
   return self:_el_repl(el, state, ListView.el_repl(self, el, state))
end

This.pats = {
   text_row  = [[<tr><td colspan={%table_wid} class="bm_text">{%text}</td></tr>]],
   quote_row = [[<tr><td colspan={%table_wid} class="bm_quote"><blockquote class="bm_quote">{%quote}</blockquote></td></tr>]],
   tag_row   = [[<tr><td colspan={%table_wid}>{%tag_html}</td></tr>]],
}

function This:_el_repl(el, state, repl)
   repl.xp = math.floor(100*repl.x + 0.5)
   repl.yp = math.floor(100*repl.y + 0.5)

   local _tag_list
   local function tag_list()
      if not _tag_list then
         _tag_list = {}
         local list = self.lister.db:cmd("get_tags")(el.id)
         print(#list)
         for k,v in pairs(list) do print(k,v) end
         for _, entry in ipairs(list) do
            table.insert(_tag_list, entry.name)
         end
      end
      return _tag_list
   end

   local function tag_fun(b, m, e)
      return function()
         return #tag_list() > 0 and (b .. table.concat(tag_list(), e .. m .. b) .. e) or " "
      end
   end
   repl.tag_html = tag_fun([[<span class="tag">]], ",", "</span>")
   repl.tag_text = tag_fun("", ",", "")

   repl.text_row =
      el.text and string.match(el.text, "[%w]*(.+)[%w]*") ~= "" and self.pats.text_row
      or " "
   repl.quote_row =
      el.quote and string.match(el.quote, "[%w]*(.*)[%w]*") ~= "" and self.pats.quote_row
      or " "
   repl.tag_row = function() return #tag_list() > 0 and self.pats.tag_row or " " end

   return repl
end

function This:rpc_js()
   local ret = ListView.rpc_js(self)

   ret[".collect"] = function(uri, title, text, quote, tag_list, pos_frac)
      print("bookmarks.collect", uri)
      print(title, text, quote, #tag_list, unpack(pos_frac))

      self.lister.db:enter{
         uri=uri, title=title, text=text, quote=quote, tags=tag_list,
         x=pos_frac[1], y=pos_frac[2], creator="self",
         }
      return "OK"
   end

   ret[".lookup_area"] = function(uri, x, y, terms)
      -- look up relevant bookmarks
      return "TODO"
   end
      
   ret[".search"] = function(terms)
   end

   return ret
end

return This
