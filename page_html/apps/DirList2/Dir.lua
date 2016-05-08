local lfs = require "lfs"
local Sql = require "Searcher.Sql"

local This = require("page_html.util.Class"):class_derive(
   Sql, { __name="page_html.apps.DirList2.Dir" })

function This:init()
   Sql.init(self)
   self:exec [[
   CREATE TABLE IF NOT EXISTS files (
     id INTEGER PRIMARY KEY,
  
     dir TEXT NOT NULL,
     file TEXT NOT NULL,
     mode TEXT NOT NULL,

     size INTEGER NOT NULL,  
     access INTEGER NOT NULL,
     modification INTEGER NOT NULL
   );
]]
   self.update_times = {}
end

This.Formulator = require "page_html.apps.DirList2.Formulator"

This.repl = { table_name = "files" }

local cmd_strs = {}
This.cmd_strs = cmd_strs

cmd_strs.select_dir  = "SELECT * FROM {%table_name} WHERE dir == ?;"
cmd_strs.select_path = "SELECT id FROM {%table_name} WHERE dir == ? AND file == ?;"
cmd_strs.delete_path = "DELETE FROM {%table_name} WHERE dir == ? AND file == ?;"

-- Enter using the autoincrement.(assuming not already exists)
cmd_strs.enter   = "INSERT INTO {%table_name} VALUES (NULL, ?,?,?, ?,?,?);"
-- (not assuming already exists)
-- TODO doesnt work for somer reason? Deletes itself?
cmd_strs.enter_replace = cmd_strs.delete_path .. cmd_strs.enter

function This:enter(entry)
   -- Delete pre-existing.
   if entry then
      self:cmd("delete_path")(entry.dir, entry.file)
      assert(not entry.id) -- Re enter.,
      self:cmd("enter")(entry.dir, entry.file, entry.mode,
                        entry.size, entry.access, entry.modification)
   end
end

local entry_from_file = lfs.attributes

function This:update_file(dir, file)  -- NOTE is this right..?
   local entry = entry_from_file(dir .. "/" .. file)
   if entry then
      entry.dir  = dir
      entry.file = file
      self:enter(entry)
   end
end

This.fresh_time = 3   -- How long a directory stays fresh enough.
local gettime = require("socket").gettime

function This:update_directory(directory)
   local update_times = self.update_times
   -- Remove gone stale.
   while #update_times > 0 and gettime() - update_times[1][1] > self.fresh_time do
      table.remove(update_times, 1)
   end

   for _, el in ipairs(update_times) do
      if el[2] == directory then return true end  -- In there, fresh.
   end

   table.insert(update_times, {gettime(), directory})

   local fd = io.open(directory)
   if fd then
      fd:close()
      for file in lfs.dir(directory) do
         self:update_file(directory, file)
      end
      return true
   end
end

return This
