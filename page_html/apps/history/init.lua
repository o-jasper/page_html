--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

--local search = require "page_html.apps.lib.search"

local ListView = require "page_html.ListView"
local This = ListView:class_derive{ __name="History", name="history" }

This.description = "Browser history as recorded by (presumably)userscript."

This.Formulator = require "page_html.apps..history.Formulator"
This.Db         = require "page_html.apps.history.History"

This.where      = {"page_html/apps/history/", "page_html/ListView/", "page_html/"}

This.full_span = 3

This.enable_mirror = true  -- Note must also be enabled in the userscript.
This.enable_view_mirror = true
This.MirrorPage = require "page_html.apps.history.MirrorPage"

function This:init()
   ListView.init(self)
end

function This:extra_list()
   if self.enable_view_mirror then
      assert(self.data_dir)
      self.mirror_page = self.MirrorPage:new{
         data_dir = self.data_dir,
         name="history_mirrored", server = self.server,
      }
      return { self.mirror_page }
   end
end

function This:el_repl(el, state)
   return self:_el_repl(el, state, ListView.el_repl(self, el, state))
end

function This:_el_repl(el, state, repl)
   -- Local version of mirror.
   repl.local_version = function(_, ...)
      return repl.insert_page_method(nil, "history_mirrored", "link_part", ...)
   end
   return repl
end

function This:rpc_js()
   local ret = ListView.rpc_js(self)

   local added = {
      collect = function(uri, title)
         print("history.collect", uri)
         self.lister.db:update{uri=uri, title=title}
         return { mirror=true }
      end,
   }
   -- Fairly rudimentary mirror.
   -- TODO move to the mirroring page?
   if self.enable_mirror then
      added["collect.mirror"] = function(uri, innerHTML)
         self.mirror_page:mirror_uri_html(uri, innerHTML)
      end
   end

   for key, fun in pairs(added) do
      ret["." .. key] = function(info, ...)
         if self.disable_dumb_pw or info.dumb_pw == self.dumb_pw then
            return fun(...)
         else
            print("Failed dumb pw for", "." .. key)
         end
      end
   end

   return ret
end

return This
