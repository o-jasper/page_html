--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local Pegasus = require "pegasus"

-- local PegasusJs = require "PegasusJs" -- Really will need it..
local This = {}
This.__index = This

This.__name = "page_html.html.pegasus"

function This:new(new)
   new = setmetatable(new or {}, self)

   new.pegasus = Pegasus:new(new.pegasus_arg or {})
   new.pegasus_arg = nil

   new.pages = new.pages or {}
   new.pages_js = new.pages_js or {}

   return new
end

function This:add(...)
   for i, page in ipairs{...} do
      self.pages[page.name] = page
      self:add(unpack(page.extra_list and page:extra_list() or {}))
   end
end

function This:_ensure_js(page)
   -- Make the javascript interfacing, as needed..
   local js = self.pages_js[page.name]
   if not js then
      js = require("PegasusJs").new{string.format("/%s/PegasusJs", page.name)}
      local rpc_js = page.rpc_js and page:rpc_js()
      if rpc_js then
         js:add(rpc_js)
      end
      self.pages_js[page.name] = js
   end
   return js
end

function This:loopfun()
   -- Lists chromes and stuff if not found.
   return function(req, rep)
      -- Get at information.
      local page_name, rest = string.match(req:path() or "", "^/([^/]+)/(.*)")
      if not page_name then
         page_name = string.match(req:path() or "/couldnt-figure-path", "^/(.+)") or "no-name"
      end

      local rest = rest or ""
      local args = {
         page_name = page_name,
         rest_path = rest,
         
         path = req:path(),
         whole = true,

         pages = self.pages,
      }
      -- Figure the page, if not, give help.
      local page = self.pages[page_name] or self.pages[page_name .. "/" .. rest]
         or require("page_html.serve.NotFound"):new(args)

      -- Response from javascript might be sufficient.
      if not self:_ensure_js(page):respond(req, rep) then
         local str, tp = page:output(args)
         rep:addHeader('Content-Type', tp or 'text/html'):write(str)
      end
   end
end

if Pegasus.prepare then
   function This:prepare(callback)
      local loopfun = self:loopfun()
      if callback then
         local function cb(req, rep)
            return callback(req, rep) or loopfun(req, rep)
         end
         self.pegasus:prepare(cb)
      else
         self.pegasus:prepare(loopfun)
      end
   end
end

function This:start()
   return self.pegasus:start(self:loopfun())
end

return This
