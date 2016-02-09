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

This.where      = {"page_html/apps/history/", "page_html/ListView/"}
This.assets_arg = {where = This.where}

-- TODO absolute..
This.data_dir = "/home/jasper/iso/newiso/server/althist/data/"
This.db_file  = This.data_dir .. "history.db"

This.full_span = 3

function This:rpc_js()
   local ret = ListView.rpc_js(self)
   ret[".collect"] = function(uri, title)
      print("history.collect", uri)
      self.lister.db:update{uri=uri, title=title}
      return { mirror=true }
   end

   ret[".collect.mirror"] = function(uri, innerHTML)
      print("history.mirror", uri)
      local dir = self.data_dir .. "mirror/" .. uri .. "/"
      os.execute("mkdir -p " .. dir)  -- Lazy
      local fd = io.open(dir .. "index.html", "w")
      if fd then
         fd:write(innerHTML)
         fd:close()
      else
         print("history.collect.mirror", "failed to open", dir .. "index.html")
      end
   end

   return ret
end

return This
