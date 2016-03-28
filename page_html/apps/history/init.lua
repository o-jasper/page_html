--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

--local search = require "page_html.apps.lib.search"

local ListView = require "page_html.ListView"

local This = {}
-- Derive from listview.
for k,v in pairs(ListView) do This[k] = v end
This.__index = This

This.name = "history"

This.Formulator = require "page_html.apps..history.Formulator"
This.Db         = require "page_html.apps.history.History"

This.where      = {"page_html/apps/history/", "page_html/ListView/", "page_html/"}
This.assets_arg = {where = This.where}

-- TODO absolute..
This.data_dir = "/home/jasper/iso/newiso/server/althist/data/"
This.db_file  = This.data_dir .. "history.db"

This.full_span = 3

This.enable_mirror = true  -- Note must also be enabled in the userscript.
This.enable_view_mirror = true
This.MirrorPage = require "page_html.apps.history.MirrorPage"

function This:init()
   ListView.init(self)
   self.mirror_dir = self.data_dir .. "mirror/"
end

function This:extra_list_data()
   local ret = ListView.extra_list_data(self)
   if self.enable_view_mirror then
      self.mirror_page = self.MirrorPage:new{
         dir=self.mirror_dir, name="history_mirrored", server = self.server,
      }
      ret["history/mirror/"] = self.mirror_page
   end
   return ret
end

function This:el_repl(el, state)
   return self:_el_repl(el, state, ListView.el_repl(self, el, state))
end

function This:_el_repl(el, state, repl)
   -- Local version of mirror.
   repl.local_version = function(...)
      return repl.insert_page_method("history_mirrored", "link_part")
   end
   return repl
end

-- local lfs = require "lfs" -- Annoying, what is `mkdir -p` equivalent..

function This:rpc_js()
   local ret = ListView.rpc_js(self)
   ret[".collect"] = function(uri, title)
      print("history.collect", uri)
      self.lister.db:update{uri=uri, title=title}
      return { mirror=true }
   end

   -- Fairly rudimentary mirror.
   -- TODO move to the mirroring page?
   if self.enable_mirror then
      ret[".collect.mirror"] = function(uri, innerHTML)
         self.mirror_page:mirror_uri_html(uri, innerHTML)
      end
   end

   return ret
end

return This
