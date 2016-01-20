local apply_subst = require "page_html.util.apply_subst"

return function(Prior)
   -- local PegasusJs = require "PegasusJs" -- Really will need it..
   local This = {}
   for k, v in pairs(Prior) do This[k] = v end
   This.__index = This

   This.__name = "page_html.html.pegasus"

   function This:new(new)
      new = Prior:new(new)
      new = setmetatable(new or {}, self)
      new.pages = new.pages or {}
      new.pages_js = new.pages_js or {}
      return new
   end

   function This:add(...)
      for i, page in ipairs{...} do
         self.pages[page.name] = page
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
      local page_not_found = {
         name = "page_not_found",
         new = function(s, args)
            s.args = args
            return s
         end,
         output = function(s)
            local patt = [[
Dont have this..<h4>args:</h4>
<table>{%list}</table>
<h4>Dont have page %s, to have pages:</h4>
<table>{%page_list}</table>
]]
            local list, page_list = {}, {}
            for k, v in pairs(s.args) do
               table.insert(list, string.format("<tr><td>%s =</td><td>%s</td></tr>", k,v))
            end
            for k, v in pairs(self.pages) do
               local val = v.name == k  and v.name or string.format("%s != %s", k, v.name)
               table.insert(page_list,
                            string.format([[<tr><td><a href="/%s/">%s</a></td></tr>]],
                               val, val))
            end

            return apply_subst(patt, {list=table.concat(list, "\n"),
                                      page_list=table.concat(page_list, "\n")})
         end,
      }

      return function(req, rep)
         -- Get at information.
         local page_name, rest = string.match(req:path() or "", "^/([^/]+)/(.*)")
         if not page_name then
            page_name = string.match(req:path() or "couldnt-figure-path", "^/(.+)")
         end
         local args = {
            page_name = page_name,
            rest_path = rest,

            path = req:path(),
            whole = true,
         }
         -- Figure the page, if not, give help.
         local page = self.pages[page_name] or page_not_found:new(args)
         -- Response from javascript might be sufficient.
         if not self:_ensure_js(page):respond(req, rep) then
            rep:addHeader('Content-Type', 'text/html'):write(page:output(args))
         end
      end
   end

   if Prior.prepare then
      function This:prepare(callback)
         local loopfun = self:loopfun()
         if callback then
            local function cb(req, rep)
               return callback(req, rep) or loopfun(req, rep)
            end
            Prior.prepare(self, cb)
         else
            Prior.prepare(self, loopfun)
         end
      end
   end
   return This
end
