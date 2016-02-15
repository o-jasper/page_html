local lfs = require "lfs"
local Assets = require "page_html.Assets"
local apply_subst = require "page_html.util.apply_subst"

local html_escape = require "page_html.util.text.html_escape"

return {
   name = "basic_dir_explorer",
   where = {"page_html/serve/examples/"},
   to_js = {},
   --repl_pattern="{%dir.html}",
   repl = function(self, args)
      local ret = { page_name = args.page_name }

      ret.directory = string.match(args.path, "^/[^/]+/(.*)$") or ""
      if ret.directory == "" then
         ret.directory = lfs.currentdir()
      end
      ret.list = "<table>"
      if lfs.attributes(ret.directory, "mode") == "directory" then
         ret.what = "Directory"
         for k,v in lfs.dir(ret.directory) do
            local attr = lfs.attributes(ret.directory .. "/" .. k)
            local k, add = html_escape(k), "<tr>"
            add = string.format(
               [[<td><a href="/{%%page_name}/{%%directory}/%s">%s%s</a></td>]],
               k, k, attr and attr.mode == "directory" and "/" or " ")
            if attr then
               add = string.format("%s<td>%d</td><td>%s</td>",
                                   add, attr.size, os.date("%c", attr.modification))
            else
               add = string.format("%s<td>(couldnt get attributes)</td>", add, k)
            end
            ret.list =  ret.list .. add .. "</tr>"
         end
         ret.list = ret.list .. "</table>"
      else
         ret.what = "File"
         for k,v in pairs(lfs.attributes(ret.directory) or {}) do
            local add = string.format("<tr><td>%s</td><td>%s</td></tr>", k, v)
            ret.list = ret.list .. add
         end
         ret.list = ret.list .. "</table>"
      end
      ret.title = html_escape(self.name .. ": " .. ret.directory)
      return ret
   end,

   output = function(self, args)
      self.assets = self.assets or Assets:new{where = self.where}
      return apply_subst(self.assets:load("basic_dir_explorer.html"), self:repl(args))
   end,
}
