local split = require "OmniPub_html.util.split"
local pkgs  = require "OmniPub_html.util.pkgs"
local list  = require "OmniPub_html.util.list"

local function open_asset(path, search_in)
   for _, dir in pairs(search_in) do
      local fd = io.open(dir .. path, "r")
      if fd then  -- Found it.
         return fd, dir
      end
   end
end

local function read_and_close(fd, path, memorize)
   local ret = fd:read("*a")
   if memorize then
      memorize[path] = ret
   end
   fd:close()
   return ret
end

local Assets = {}
Assets.__index = Assets

Assets.__name = "omniPub_html.Assets"

Assets.memoize = {}

-- NOTE: this breaks with package.path changes after.
-- (doing that is not wise in the first place)
Assets.search_from = list(pkgs(package.path))

function Assets:new(new)
   new = setmetatable(new or {}, self)
   if new.memoize == true then new.memoize = nil end
   assert(new.memoize == false or type(new.memorize) == "table")
   new.where = new.where or {"assets/"}
   return new
end

-- Load asset directly, dont search.(path needs to be exact)
function Assets:load_direct(exact_path)
   if self.memorize and self.memorize[exact_path] then
      return self.memorize[exact_path]
   end
   local got, _ = open_asset(exact_path, self.search_from)
   if got then
      return read_and_close(got, exact_path, self.memorize)
   end
end

-- Search asset, return opened if exists.
function Assets:open(path)
   for _, where_path in pairs(self.where) do
      -- * Indicates to search parents of the directory aswel afterwards.
      if string.match(where_path, "^[*]") then
         local splitpath = list(split(string.sub(where_path, 2), "/"))
         while #splitpath > 0 do
            local cur_path = table.concat(splitpath, "/") .. "/" .. path
            local got, _ = open_asset(cur_path, self.search_from)
            if got then
               return got, cur_path
            end
            table.remove(splitpath)
         end
      else
         local got, _ = open_asset(where_path ..path, self.search_from)
         if got then
            return got, where_path ..path
         end
      end
   end
end

-- Returns just a particular path.
function Assets:path(path)
   local got, at_path = self:open(path)
   if got then
      got:close()  -- Dont really want to read; close.
      return at_path
   end   
end

function Assets:load(path)
   local got, at_path = self:open(path)
   if got then
      return read_and_close(got, at_path, self.memorize)
   end
end

return Assets
