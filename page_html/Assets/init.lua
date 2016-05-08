--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local split = require "page_html.util.split"
local pkgs  = require "page_html.util.pkgs"
local list  = require "page_html.util.list"

local function open_asset(path, search_in)
   for _, dir in pairs(search_in) do
      local fd = io.open(dir .. "/" .. path, "r")
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

local Assets = require("page_html.util.Class"):class_derive{__name="page_html.Assets"}

Assets.prefix = "assets/"

Assets.memoize = {}

-- NOTE: this breaks with package.path changes after.
-- (doing that is not wise in the first place)
Assets.search_from = {}

for _, path in pkgs(package.path) do
   table.insert(Assets.search_from, string.sub(path, 1, -7))
end

function Assets:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end

function Assets:init()
   if self.memoize == true then self.memoize = nil end
   assert(self.memoize == false or type(self.memoize) == "table")
   self.where = self.where or {"/"}
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
   path = self.prefix .. path
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
         local got, _ = open_asset(where_path .. path, self.search_from)
         if got then
            return got, where_path .. "/" .. path
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

function Assets:if_not_found(path)
   print(string.format("Asset not found: %s\n", path))
end

function Assets:load(path)
   local got, at_path = self:open(path)
   if got then
      return read_and_close(got, at_path, self.memorize)
   else
      self:if_not_found(path)
   end
end

return Assets
