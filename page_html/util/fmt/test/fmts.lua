local fmts = { escapeless = require "Searcher.escapeless",
               base64    = require "page_html.util.fmt.base64"
}

for _ = 1,2 do

   local fd = io.open("/dev/random")
   local data = fd:read(10*string.byte(fd:read(1)) + string.byte(fd:read(1)))
   fd:close()
   
   for k, fmt in pairs(fmts) do
      local ed = fmt.enc(data)
      local got = fmt.dec(ed)
      assert( data == got, string.format("%s WRONG\nenc:%s\npre:%s\naft:%s", k, ed, data, got))
   end
end
