
local figure_required = require "lib.figure_required"

for k,v in pairs(figure_required.file(arg[1])) do print(k, unpack(v)) end
