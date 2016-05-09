local tmpdir = "/tmp/pydoc/"

local exec = require "page_html.util.exec"
exec([[mkdir -p "%s"]], tmpdir)

return function(_, query)
   exec([[bash -c "cd %s; pydoc -w %s"]], tmpdir, query)
   return string.format("file://%s%s.html", tmpdir, query)
end
