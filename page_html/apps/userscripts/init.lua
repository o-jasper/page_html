local This = require("page_html.util.Class"):class_derive{
   name="userscripts", __name="page_html.apps.userscripts" }

This.Assets = require "page_html.Assets"

This.where = {"page_html/apps/userscripts/", "page_html/", "page_html/ListView/"}

function This:init()
   self.assets_arg = self.assets_args or {where = This.where}
   self.assets = self.Assets:new(self.assets_arg)
end

local apply_subst = require "page_html.util.apply_subst"

function This:output(args)
   local assets = self.assets

   if string.match(args.rest_path, "[.]user[.]js$") then
      local ret = assets:load("userscripts/" .. args.rest_path)
      if ret then
         local function index(_, key) 
            local prep, asset = "// - " .. key .. "\n", assets:load(key)
            if string.match(key, "[.]css$") or string.match(key, "[.]htm") then
               return prep .. string.gsub(asset, "([^\n]+)",
                                          function(x) return [[h += "]] .. x .. [[";]] end)
            else
               return prep .. (asset or "ASSET " .. key .. "NOT FOUND")
            end
         end
         return apply_subst(ret, setmetatable({}, {__index=index}),
                            256, "{%%([%w_/]+[.][%w_./]+)[%s]*([^}]*)}"), "text/javascript"
      else
         return "No such userscript."
      end
   else  -- TODO use an asset..
      local userscript_list = {}
      local bare_list = {
         {"althist.user.js",  "Logs history for you. Also mirrors."},
         {"commands.user.js", "Run commands"},
         {"althist.mirror.user.js",
          "Mirrors <code>.innerHTML</code>, the regular althist defaultly already does!"}
      }
      for _, el in ipairs(bare_list) do
         table.insert(userscript_list,
                      string.format([[{%%userscript %s}<td></td>%s]], unpack(el)))
      end

      local repl = { table="<table><tr><td>"  ..
                        table.concat(userscript_list, "</td></tr>\n<tr><td>") ..
                        "<tr><td></td></tr></table>",
                     table_cnt=#bare_list,
                     userscript = function(_, which)
                        return string.format(
                           [[<a href="/userscripts/%s"><code>%s</code></a>]],
                           which,which)
                     end,
      }
      return apply_subst(assets:load("page/front.html"), repl)
   end
end

return This
