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

-- TODO only really do anything if staler-than..
function This:init()
   self.dir_sql = self.Dir:new{filename=self.db_filename}
   assert(self.dir_sql)
   self:to_dir(self.at_path)
end

function This:to_dir(path)
   local path = path or self.at_path or os.getenv("HOME")
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
   --require "page_html.apps.DirList.info_on.basic_file"
   require "page_html.apps.DirList.info_on.file"
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
   return function(term, state, ...)
      state.to_dir = state.to_dir or self.at_dir
      self:to_dir(state.to_dir)

      local list = search(self.dir_sql, self.Formulator, self.allow_direct)(term, state, ...)
      local info_list = info_on.list(list, self, self.info_ons)

      -- TODO might want to select higher-priority ones for each entry.

      state.where = self.where
      return ret_list(info_list, state)
   end
end

function This:repl(state)
   self:to_dir(state.rest_path)
   return {}
end

return This
