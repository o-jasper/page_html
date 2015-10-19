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

   self.at_dir = self.at_dir or os.getenv("HOME")
end

function This:to_dir(path)
   local path = path or self.at_dir
   self.dir_sql:update_directory(path)
   self.at_dir = path

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

This.rpc_js = {}

function This.rpc_js:to_dir(path)
   self.rpc_js.search(self)("", { to_dir=path })
end

local ret_list = require "page_html.apps.lib.ret_list"
local info_on  = require "page_html.info_on"
-- TODO defaultly need a current_directory..
function This.rpc_js:search(term, state, ...)
   assert(self.dir_sql)
   print("----------------------")
   state.to_dir = state.to_dir or self.at_dir or os.getenv("HOME")

   self:to_dir(state.to_dir)

   local form = search(self.Formulator, self.allow_direct)(term, state, ...)
   form:equal("dir", state.to_dir)

   print("Q", form:sql_pattern())
   local list = nil
   pcall(function()
         list = self.dir_sql:exec(form:sql_pattern(), unpack(form:sql_values()))
   end)  -- TODO handle failure?
   local info_list = list and info_on.list(list, self, self.info_ons) or {}

   -- TODO might want to select higher-priority ones for each entry.
   state.where = self.where
   return ret_list(info_list, state)
end

function This:repl(state)
   self.at_dir = state.rest_path or "/"
   if not string.find(self.at_dir, "^/") then
      self.at_dir = os.getenv("HOME") .. "/" .. self.at_dir
   end
   return {}
end

return This
