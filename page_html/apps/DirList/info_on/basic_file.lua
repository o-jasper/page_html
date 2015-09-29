-- Shows readme functions and/or 

local c = require "o_jasper_common"
local lfs = require "lfs"

local This = {}
This.__index = This

function This:new(new) return setmetatable(new, self) end

function This:priority()
   return 0
end

This.other_format = "<td><small>%s:%s</small></td>"
This.head = "<td>{%mode}</td><td>{%dir}</td><td>{%file}</td>"

local apply_subst = require "page_html.util.apply_subst"

function This:output()  -- TODO not allowed to touch local shit..
   local fp = self.dir .. "/" .. self.file
   local ret, attrs = {}, lfs.attributes(fp) or {}
   attrs.file = self.file
   attrs.dir  = self.dir
   attrs.mode = attrs.mode == "directory" and "dir" or attrs.mode

   table.insert(ret, apply_subst(This.head, attrs))

   attrs.file = nil
   attrs.dir = nil
   attrs.mode = nil
   for k,v in pairs(attrs) do
      table.insert(ret, string.format(self.other_format, 
                                      k,v))
   end
   return table.concat(ret)
end

return This
