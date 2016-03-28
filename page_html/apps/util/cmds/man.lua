local tmpdir = "/tmp/man/"

os.execute("mkdir -p " .. tmpdir)

return function(_, query)
   local to_file = tmpdir .. query .. ".html"
   os.execute([[man --html="cat %s > ]] .. to_file .. "\" " .. query)
   return "file://" .. to_file
end
