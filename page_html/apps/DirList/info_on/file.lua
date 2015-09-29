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

function This:ms_t() return self.modification * 1000 end

local time = require "page_html.util.text.time"
function This:repl(state)
   local repl = self.attrs or {}
   repl.file = self.file
   repl.dir  = self.dir
   repl.time = function(instruction)
      return time.instructed(instruction, state, self:ms_t(), self.config)
   end
   return repl
end

return This
