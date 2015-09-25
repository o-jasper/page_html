local lfs = require "lfs"

return {
   name = "basic_dir_explorer",
   where = {"omniPub_html/serve/examples/"},
   to_js = {},
   --repl_pattern="{%dir.html}",
   repl = function(self, meta)
      local ret = {}

      ret.directory = string.match(meta.path, "^/[^/]+/(.*)$") or ""
      if ret.directory == "" then
         ret.directory = lfs.currentdir()
      end
      ret.list = ""
      for k,v in lfs.dir(ret.directory) do
         local attr = lfs.attributes(ret.directory .. "/" .. k)
         local add = "<tr>"
         add = string.format(
            [[<td><a href="/{%%page_name}/{%%directory}/%s">%s/</a></td>]],
            k, k)
         if attr then
            add = string.format("%s<td>%d</td><td>%s</td>", 
                                add, attr.size, os.date("%c", attr.modification))
         else
            add = string.format("%s<td>(couldnt get attributes)</td>", add, k)
         end
         ret.list =  ret.list .. add .. "</tr>"
      end
      return ret
   end
}
