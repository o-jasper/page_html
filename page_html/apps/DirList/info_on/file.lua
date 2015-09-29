local lfs = require "lfs"

local This = {}

for k,v in pairs(require "page_html.apps.DirList.info_on.basic_file") do 
   This[k] = v
end

for k,v in pairs(require "page_html.serve.Suggest") do 
   This[k] = v
end

This.__index = This
assert(This.init)

This.name = "info_on/file"

function This:priority()
   return (string.match(self.file, "^[.]#.+") and -2) or 0
end

--function This:ms_t() return self.modification * 1000 end

local time_instructed = require("page_html.util.text.time").instructed
local text_gist = require("page_html.util.text.number").gist
function This:repl(state)
   local repl = self.attrs or {}
   repl.file = self.file
   repl.dir  = self.dir
   repl.time = function(instruction)
      return time_instructed(instruction, state, self.modification*1000, self.config)
   end
   repl.access_time = function(instruction)
      return time_instructed(instruction, state, self.access*1000, self.config)
   end
   local mode = repl.mode
   repl.mode = function(instruction)
      if instruction == "letter" then
         return string.sub(mode, 1,1)
      else
         return mode
      end
   end
   local size = repl.size
   repl.size = function(instruction)
      if instruction == "gist" then
         return text_gist(size)
      else
         return size
      end
   end
   repl.resay_colspan = 3
   return repl
end

return This
