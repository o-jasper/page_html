local tmpdir = "/tmp/man/"
local exec = require "page_html.util.exec"

exec([[mkdir -p "%s"]], tmpdir)

return function(_, query)
   -- TODO just serve it directly instead.
   local to_file = tmpdir .. query .. ".html"
   exec([[man --html="cat %%s > %s" %s]], to_file, query)
   return "file://" .. to_file
end
