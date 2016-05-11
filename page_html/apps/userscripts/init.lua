local GotAssets = require "page_html.GotAssets"

local This = GotAssets:class_derive{
   name="userscripts", __name="page_html.apps.userscripts" }

This.description = "Can load userscripts from here."

This.where = {"page_html/apps/userscripts/", "page_html/", "page_html/ListView/"}

function This:init()
   GotAssets.init(self)

   if not self.ge_prep then
      local prepfile = self.data_dir .. "/userscript_prep"
      local fd = io.open(prepfile)
      if fd then
         self.ge_prep = fd:read("*a")
      else
         local large = math.floor(256^5)  -- Just for uniqueness.(really, overkill
         math.randomseed(os.time() + math.floor(large*os.clock()))
         local function r() return math.random(large) end
         self.ge_prep = string.format("R%x%x_", r(),r())

         fd = io.open(prepfile, "w")  -- Write it down.
         fd:write(self.ge_prep)
         fd:close()
      end
   end
end

local apply_subst = require "page_html.util.apply_subst"

function This:output(args)
   local assets = self.assets

   if string.match(args.rest_path, "[.]user[.]js$") then
      local ret = assets:load("userscripts/" .. args.rest_path)
      if ret then
         local function index(_, key) 
            if key == ".prep" then
               return self.ge_prep
            end

            local prep, asset = "// - " .. key .. "\n", assets:load(key)
            assert(asset, "Could not find asset: " .. key)
            if string.match(key, "[.]css$") or string.match(key, "[.]htm") then
               return prep .. string.gsub(asset, "([^\n]+)",
                                          function(x) return [[h += "]] .. x .. [[";]] end)
            elseif key == "js/common.js" then
               return prep .. asset .. "\n" .. [[ge_prep = "]] .. self.ge_prep .. [[";]]
            elseif asset then
               return prep .. asset
            else
               return prep .. "ASSET " .. key .. "NOT FOUND"
            end
         end
         return apply_subst(ret, setmetatable({}, {__index=index}),
                            256, "{%%([%w_/]*[.][%w_./]+)[%s]*([^}]*)}"), "text/javascript"
      else
         return "No such userscript: " .. args.rest_path
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
                      string.format([[{%%userscript %s}</td><td>%s]], unpack(el)))
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
