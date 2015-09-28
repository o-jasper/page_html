return function(startfun)
   -- local PegasusJs = require "PegasusJs" -- Really will need it..
   
   local Suggest = require "page_html.serve.Suggest"
   
   local This = {}
   This.__index = This
   
   This.__name = "page_html.html.pegasus"
   
   function This:new(new)
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
         local PegasusJs = require "PegasusJs"
         
         js = PegasusJs.new{string.format("/%s/PegasusJs", page.name)}
         local funs = (type(page.rpc_js) == "function" and page:rpc_js()) or
            page.rpc_js or {}
         local add_funs = {}
         for k,v in pairs(funs) do add_funs[k] = v(page) end
         js:add(add_funs)
         self.pages_js[page.name] = js
      end
      return js
   end
   
   function This:start()
      -- Lists chromes and stuff if not found.
      local function help_if_not_found(args)
         --html = string.format("<p>Try.. %d</p> %s %s %s <p>%s %s</p>", k, req.path,
         -- t, t2, args.page, args.path)
         local html = "Dont have this..<h4>args:</h4><table>"
         for k, v in pairs(args) do
            html = html .. string.format("<tr><td>%s =</td><td>%s</td></tr>", k,v)
         end
         html = html .. "</table>" ..
            string.format("<h4>Dont have page %s, to have pages:</h4><table>",
                          chrome_name)
         for k, v in pairs(self.pages) do
            local val = v.name == k  and v.name or
               string.format("%s != %s", k, v.name)
            html = html .. string.format([[<tr><td><a href="/%s/">%s</a></td></tr>]],
               val, val)
         end
         return html .. "</table>"
      end
      
      -- TODO/NOTE: fairly messy, 
      startfun(function(req, rep)
            -- Get at information.
            local page_name, rest = string.match(req:path() or "", "^/([^/]+)/(.*)")
            if not page_name then
               page_name = string.match(req:path(), "^/(.+)")
            end
            
            local args = {
               page_name = page_name,
               rest_path = rest,
               
               path = req:path(),
               whole = true,
            }
            -- Figure the page, if not, give help.
            local page = self.pages[page_name]
            if not page then  -- Cant find the page..
               rep:addHeader('Content-Type', 'text/html'):write(help_if_not_found(args))
            else
               -- Response from javascript might be sufficient.
               if self:_ensure_js(page):respond(req, rep) then return end
               -- Injection of the javascript needed to interface.
               args.inject_js = string.format(
                  [[<script type="text/javascript" src="/%s/PegasusJs/index.js"></script>]],
                  page_name
               )
               local html = (page.output or Suggest.output)(page, args)
               rep:addHeader('Content-Type', 'text/html'):write(html)
            end
      end)
   end
   
   return This
end
