local lfs = require "lfs"

return {
   name = "basic_dir_explorer",
   where = {"page_html/serve/examples/"},
   to_js = {},
   --repl_pattern="{%dir.html}",
   repl = function(self, meta)
      local ret = {}

      ret.directory = string.match(meta.path, "^/[^/]+/(.*)$") or ""
      if ret.directory == "" then
         ret.directory = lfs.currentdir()
      end
      ret.list = "<table>"
      if lfs.attributes(ret.directory, "mode") == "directory" then
         ret.what = "Directory"
         for k,v in lfs.dir(ret.directory) do
            local attr = lfs.attributes(ret.directory .. "/" .. k)
            local add = "<tr>"
            add = string.format(
               [[<td><a href="/{%%page_name}/{%%directory}/%s">%s%s</a></td>]],
               k, k, attr.mode == "directory" and "/" or " ")
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
         for k,v in pairs(lfs.attributes(ret.directory)) do
            local add = string.format("<tr><td>%s</td><td>%s</td></tr>", k, v)
            ret.list = ret.list .. add
         end
         ret.list = ret.list .. "</table>"
      end
      return ret
   end
}
