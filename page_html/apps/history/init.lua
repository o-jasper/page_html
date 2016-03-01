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
      ret["history/mirror/"] = self.MirrorPage:new{
         dir=self.mirror_dir, name="history_mirrored"
      }
   end
   return ret
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
         if string.find(uri, string.format("^https?://localhost:%s/history_mirrored/",
                                           self.server.port or 9090)) then
            print("Excluded from mirror collection", uri)
            return
         end
         local dir =  self.mirror_dir .. uri
         print("history.mirror", dir)
         os.execute("mkdir -p " .. dir)
         local fd = io.open(dir .. "/index.html", "w")
         if fd then
            fd:write(innerHTML)
            fd:close()
         else
            print("history.collect.mirror", "failed to open", dir .. "/index.html")
         end
      end
   end

   return ret
end

return This
