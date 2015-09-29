local This = {}

This.__index = This
This.__name = "page_html.apps.DirList"

This.Dir = require "page_html.apps.DirList.Dir"
This.Formulator = require "page_html.apps.DirList.Formulator"

function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

This.db_filename = ":memory:"

function This:init()
   self.dir_sql = self.Dir:new{filename=self.db_filename}
   assert(self.dir_sql)
   self:to_dir(self.at_path)
end

function This:to_dir(path)
   local path = path or "/home/jasper/proj/decentreddit/page_html/page_html" --os.getenv("HOME")
   self.at_path = path
   self.dir_sql:update_directory(path)

   -- NOTE wont update html out there until they update themselves.
end

This.name = "DirList"
This.where = { "page_html/apps/DirList/", "page_html/apps/", }

This.allow_direct = { limit = 2 }  -- Just limit.

local search = require "page_html.apps.lib.search"

This.thresh = -1
This.info_ons = {
   require "page_html.apps.DirList.info_on.basic_file"
}

local rpc_js = {}
This.rpc_js = rpc_js

function rpc_js:to_dir()
   return function(path)
      self.rpc_js.search(self)("", { to_dir=path })
   end
end

local ret_list = require "page_html.apps.lib.ret_list"
local info_on  = require "page_html.info_on"
-- TODO defaultly need a current_directory..
function rpc_js:search()
   assert(self.dir_sql)
   return function(term, info, ...)
      if info.to_dir then
         self:to_dir(info.to_dir)
      end
      local list = search(self.dir_sql, self.Formulator, self.allow_direct)(term, info, ...)

      --local list = self.dir_sql:exec("SELECT * FROM files")
      -- Highest-priority one.
      local info_list = info_on.list(list, self, self.info_ons)
      return ret_list(info_list, info)
   end
end

function This:repl()
   return {}
end

return This
