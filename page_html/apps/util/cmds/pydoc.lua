local tmpdir = "/tmp/pydoc/"

os.execute("mkdir -p " .. tmpdir)

return function(_, query)
   os.execute(string.format([[bash -c "cd %s; pydoc -w %s"]], tmpdir, query))
   return string.format("file://%s%s.html", tmpdir, query)
end
