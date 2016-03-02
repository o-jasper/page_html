
local figure_required = require "lib.figure_required"

os.execute("mkdir -p build/")

for k,v in pairs(figure_required.file(arg[1])) do
   local dir, file = unpack(v)
   os.execute("mkdir -p build/" .. (string.match(file, "^([%w_/]+)/[%w_]+[.]lua$") or ""))
   os.execute("cp -uv " .. dir .. file .. " build/" .. file)
end
