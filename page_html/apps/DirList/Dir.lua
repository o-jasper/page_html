local lfs = require "lfs"
local Sql = require "Searcher.Sql"

local This = {}

for k,v in pairs(Sql) do This[k] = v end

This.__index = This

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

This.__name = "page_html.apps.DirList.Dir"

This.Formulator = require "page_html.apps.DirList.Formulator"

This.repl = { table_name = "files" }

local cmd_strs = {}
This.cmd_strs = cmd_strs

cmd_strs.select_dir  = "SELECT * FROM {%table_name} WHERE dir == ?"
cmd_strs.select_path = "SELECT id FROM {%table_name} WHERE dir == ? AND file == ?"
cmd_strs.delete_path = "DELETE FROM {%table_name} WHERE dir == ? AND file == ?"

-- Enter using the autoincrement.
cmd_strs.enter       = "INSERT INTO {%table_name} VALUES (NULL, ?,?,?, ?,?,?)"

function This:enter(entry)
   -- Delete pre-existing.
   self:cmd("delete_path")(entry.dir, entry.file)
   if entry then
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
   while #update_times > 0 and update_times[1][1] - gettime() > self.fresh_time do
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
