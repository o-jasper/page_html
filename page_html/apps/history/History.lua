local Sql = require "Searcher.Sql"

local This = {}

for k,v in pairs(Sql) do This[k] = v end

This.__index = This

function This:init()
   self.db_filename = self.filename
   Sql.init(self)
   self:exec [[
CREATE TABLE IF NOT EXISTS history (
  id INTEGER PRIMARY KEY,

  uri   TEXT NOT NULL,
  title TEXT NOT NULL,

  last   INTEGER NOT NULL,
  visits INTEGER NOT NULL
);
]]
end

This.__name = "page_html.apps.history.History"

This.Formulator = require "page_html.apps.history.Formulator"

This.repl = { table_name = "history" }

local cmd_strs = {}
This.cmd_strs = cmd_strs

cmd_strs.find_last = [[SELECT id FROM history WHERE uri == ?
ORDER BY last DESC
LIMIT 1;]]
cmd_strs.enter     = "INSERT INTO history VALUES (NULL, ?, ?, ?, 1);"
cmd_strs.incr      = "UPDATE history SET visits = visits + 1, last = ? WHERE id = ?;"
cmd_strs.del       = "DELETE FROM history WHERE id == ?;"

function This:update(entry)
   local got = self:cmd("find_last")(entry.uri)[1]
   if got then  -- Just increment it.
      self:cmd("incr")(entry.last or os.time(), got.id)
   else  -- Add it anew.
      self:cmd("enter")(entry.uri, entry.title, entry.last or os.time())
   end
end

function This:delete(entry)
   self:cmd("del")((type(entry) == "table" and entry.id) or entry)
end

return This
