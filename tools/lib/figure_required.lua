local search_dirs = {} -- Directories where assets may be.

string.gsub(";" .. require("package").path .. ";", ";([^;]+);",
            function(str)
               if str ~= "" and string.find(str, "/%?.lua$") then
                  table.insert(search_dirs, string.sub(str, 1,-6))
               end
end)

local function figure_required_require(pkg, reqs)
   local reqs = reqs or {}
   assert(type(pkg) == "string", pkg)

   local rel = string.gsub(pkg, "[.]", "/")
   local rel = { dir = rel .. "/init.lua", file = rel .. ".lua" }

   for _, dir in ipairs(search_dirs) do
      for name, file in pairs(rel) do
         local fd = io.open(dir .. file)
         if fd then  -- Found the file.
            reqs[pkg] = {dir, file}
            return reqs, {dir, file}
         end
      end
   end
end

local function figure_required_file(file, reqs)
   local fd = type(file) == "string" and io.open(file) or file
   assert(fd, file)

   local reqs, new_reqs = reqs or {}, {}
   while true do
      local line = fd:read("l")
      if line then
         -- Everything that matches a pattern for a _simple_ require goes.
         string.gsub(line, [[require[%s]*%(?[%s]*"([%w._]+)"[%s]*%)?]],
                     function(pkg)
                        new_reqs[pkg] = (not reqs[pkg] or nil) and pkg
         end)
      else
         fd:close()
         -- go into reqs, return.
         for pkg in pairs(new_reqs) do
            if not ({os=true, package=true, math=true,io=true})[pkg] then
               local _, pos = figure_required_require(pkg, reqs)
               if pos then
                  figure_required_file(pos[1] .. pos[2], reqs)
               end
            end
         end
         return reqs
      end
   end
end

return { file = figure_required_file, require = figure_required_require }
