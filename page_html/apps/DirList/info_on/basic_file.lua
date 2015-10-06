-- Shows readme functions and/or 
local lfs = require "lfs"

local This = {}
This.__index = This

This.name = "basic_file"

function This:new(new)
   new = setmetatable(new, self)
   new:init()
   return new
end

function This:init()
   self.attrs = lfs.attributes(self.dir .. "/" .. self.file)
end

function This:priority()
   return 0
end

This.other_format = "<td><small>%s:%s</small></td>"
This.head = "<td>{%mode}</td><td>{%dir}</td><td>{%file}</td>"

local apply_subst = require "page_html.util.apply_subst"

function This:output()  -- TODO not allowed to touch local shit..
   local ret, repl = {}, self.attrs or {}
   repl.file = self.file
   repl.dir  = self.dir

   repl.mode = self.mode == "directory" and "dir" or self.mode

   table.insert(ret, apply_subst(self.head, repl))

   repl.file = nil
   repl.dir = nil
   repl.mode = nil
   for k,v in pairs(repl) do
      table.insert(ret, string.format(self.other_format, 
                                      k,v))
   end
   return table.concat(ret)
end

return This
