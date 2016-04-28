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

This.table_wid = 4
This.master_css = "master_bm"

function This:extra_list_data()
   local ret = ListView.extra_list_data(self)
   ret["css/master_bm.css"] = true
   ret["css/bm.css"] = true
   return ret
end

-- TODO extend the alt-list with position-percentages.
-- TODO also want tags to show.
function This:el_repl(el, state)
   return self:_el_repl(el, state, ListView.el_repl(self, el, state))
end

This.pats = {
   text_row  = [[<tr><td colspan={%table_wid} class="bm_text">{%text}</td></tr>]],
   quote_row = [[<tr><td colspan={%table_wid} class="bm_quote">
<blockquote class="bm_quote">{%quote}</blockquote></td></tr>]],
   tag_row   = [[<tr><td colspan=2></td>
<td colspan={%table_wid-2}>{%tag_html}</td></tr>]],
}

function This:_el_repl(el, state, repl)
   repl.xp = math.floor(100*repl.x + 0.5)
   repl.yp = math.floor(100*repl.y + 0.5)

   local _tag_list
   local function tag_list()
      if not _tag_list then
         _tag_list = self.lister.db:get_tags(el.id)
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

   repl.text_row = function()
      return el.text and string.find(el.text, "[^%s]") and self.pats.text_row or " "
   end
   repl.quote_row = function()
      return el.quote and string.find(el.quote, "[^%s]") and self.pats.quote_row or " "
   end
   repl.tag_row = self.pats.tag_row
   --return #tag_list() > 0 and self.pats.tag_row or " " end

   -- Local version of mirror.
   repl.local_version = function(...)
      return repl.insert_page_method("history_mirrored", "link_part")
   end

   return repl
end

-- Modify uris as from local server.  (hmm bit lacking in extendability?)
function This:uri_mod(uri)
   for _, name in ipairs{"rh", "uri"} do
      local m = string.format("^https?://localhost:%s/comments/%s/(.+)$",
                              self.server.port or "9090", name)
      local ret = string.match(uri, m)
      if ret then
         if string.find(ret, "[%w%+]+") then ret = "comment:" .. ret .. "/" end
         return ret
      end
   end
   return uri
end

function This:rpc_js()
   local ret = ListView.rpc_js(self)

   ret[".collect"] = function(uri, title, text, quote, tag_list, pos_frac)
      local uri = self:uri_mod(uri)

      print("bookmarks.collect", uri)
      print(title, text, quote, #tag_list, unpack(pos_frac))

      self.lister.db:enter{
         uri=uri, title=title, text=text, quote=quote, tags=tag_list,
         x=pos_frac[1], y=pos_frac[2], creator="self",
      }
      return "OK"
   end

   ret[".make_quickmark"] = function(uri, title, name, pos_frac)
      self.lister.db:enter{ uri=uri, title=title, text=name, quote="",
                            tags={":quickmark"}, x=pos_frac[1], y=pos_frac[2],
                            creator="self" }
   end

   -- Get quickmarks belonging to name.
   ret[".get_quickmarks"] = function(name)
      return self.lister.db:cmd("get_quickmarks")
   end
   ret[".get_quickmarks_html"] = function(name)  -- Get a list of such.
      local list = self.lister.db:cmd("get_quickmarks")(name)
      print("QM", name, #list)
      return {self:list_html_list(list, {}, nil), list}
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
