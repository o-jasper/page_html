local split = require "omniPub_html.util.split"

local function pkgs(package_path)
   local snext = split(package_path or package.path, ";")
   local function next(prev, str)
      local k, v = snext(prev, str)
      while k and string.sub(v, -6) ~= "/?.lua" do
         k, v = snext(k)
      end
      return k,v
   end
   return next, package_path
end

return pkgs
