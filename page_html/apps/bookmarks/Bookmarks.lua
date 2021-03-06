--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Sql = require "Searcher.Sql"

local This = require("page_html.util.Class"):class_derive(
   Sql, { __name = "page_html.apps.bookmarks.Bookmarks" })

function This:init()
   self.db_filename = self.filename
   Sql.init(self)
   self:exec [[
CREATE TABLE IF NOT EXISTS bookmarks (
  id INTEGER PRIMARY KEY,

  uri   TEXT NOT NULL,
  title TEXT,

  text  TEXT,
  quote TEXT,

  time INTEGER,

  x INTEGER,
  y INTEGER,

  root_hash TEXT
);]]
   self:exec [[
CREATE TABLE IF NOT EXISTS bookmark_tags (
  id    INTEGER PRIMARY KEY,
  to_id INTEGER NOT NULL,

  name  TEXT NOT NULL
);
]]
end

This.Formulator = require "page_html.apps.bookmarks.Formulator"

This.repl = { table_name = "bookmarks" }

local cmd_strs = {}
This.cmd_strs = cmd_strs

cmd_strs.enter     = "INSERT INTO bookmarks VALUES (?, ?,?, ?,?, ?, ?,?, ?);"
cmd_strs.enter_tag = "INSERT INTO bookmark_tags VALUES (NULL, ?,?);"

cmd_strs.del_tags = "DELETE FROM bookmark_tags WHERE to_id = ?;"
cmd_strs.del = "DELETE FROM bookmarks WHERE id == ?;" .. cmd_strs.del_tags

cmd_strs.get = "SELECT * FROM bookmarks WHERE id == ?"

This.last_time = 0

function This:enter(entry)
   local t = 1000*os.time()
   if t == self.last_id then t = self.last_id + 1 end
   self.last_id = t
   self:cmd("enter")(t, entry.uri,entry.title,  entry.text,entry.quote,
                     entry.time or os.time(), entry.x, entry.y, entry.root_hash or "")

   for _, name in ipairs(entry.tags or {}) do
      self:cmd("enter_tag")(t, name)
   end
end

function This:delete(entry)
   local id = (type(entry) == "table" and entry.id) or entry
   self:cmd("del")(id, id)
end

cmd_strs._alter_entry =
   [[UPDATE bookmarks
SET uri=?, title=?, text=?, quote=?, time=?, x=?, y=? root_hash = ? WHERE id = ?;]]

function This:alter_entry(entry)
--   self:cmd("_alter_entry")(entry.uri, entry.title, entry.text, entry.quote, entry.time,
--                            entry.x, entry.y, entry.root_hash, entry.id)
   -- This part dumb remove-and-re-add.
   self:cmd("del")(entry.id, entry.id)
   self:enter(entry)
end

cmd_strs.get_tags        = "SELECT name FROM bookmark_tags WHERE to_id == ?;"
cmd_strs.get_tags_sorted = "SELECT name FROM bookmark_tags WHERE to_id == ? ORDER BY name;"
function This:get_tags(id, dont_sort)
   local ret, fun = {}, self:cmd(dont_sort and "get_tags" or "get_tags_sorted")
   for _, entry in ipairs(fun(id)) do
      table.insert(ret, entry.name)
   end
   return ret
end

-- Produces a stripped down version. (removing root hash and creator to prevent circularity.)
function This:strip(entry)  -- TODO not sure if useful.
   if entry then
      entry.id        = nil
      entry.root_hash = nil
      entry.tags    = self:cmd("get_tags_ordered")(bookmark_id)
      return entry
   end
end

cmd_strs.get_id = "SELECT * FROM bookmarks WHERE id == ?"
function This:get_id(id)
   local got = (self:cmd("get_id")(id) or {})[1]
   got.tags = self:get_tags(id)
   got.id = id
   return got
end

cmd_strs.get_root_hash = "SELECT * FROM bookmarks WHERE root_hash == ?"
function This:get_root_hash(root_hash) return self:cmd("get_root_hash")(root_hash) end

cmd_strs.set_root_hash = "UPDATE bookmarks SET root_hash = ? WHERE id = ?;"
function This:set_root_hash(id, root_hash) return self:cmd("set_root_hash")(root_hash, id) end

cmd_strs.get_quickmarks = [[SELECT * FROM bookmarks
WHERE EXISTS (SELECT * FROM bookmark_tags WHERE name == ':quickmark')
AND text == ?;
]]

return This
