local ListView = require "page_html.ListView"

local This = ListView:class_derive{ __name="DirList2", name="DirList2" }

This.db_file = ":memory:"

This.description = "Very unfinished directory browser."

This.Formulator = require "page_html.apps.DirList2.Formulator"
This.Db = require "page_html.apps.DirList2.Dir"

This.where = {"page_html/ListView/", "page_html/apps/DirList2/", "page_html/"}
This.assets_arg =  { where = This.where }

function This:init()
   self.assets = self.Assets:new(self.assets_arg)
   self.lister = require("Searcher.ProduceList"):new{
      Formulator = self.Formulator,
      db         = self.Db:new{ filename = self.db_file }
   }
end

This.table_wid = 5

function This:el_repl(el, state)
   local ret = ListView.el_repl(self, el, state)
   -- TODO add the "smalter quantities" stuff

   ret.smode = el.mode == "directory" and "dir" or el.mode
   ret.path  = el.dir .. el.file
   return ret
end

function This:repl(args)
   self.lister.db:update_directory(args.rest_path or "/")
   return ListView.repl(self)
end

return This
