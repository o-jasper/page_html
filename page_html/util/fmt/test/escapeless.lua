local escapeless = require "page_html.util.fmt.escapeless"

local fd = io.open("/dev/stdin")

local data = fd:read("*a")
local ed = escapeless.enc(data)

print(ed)
assert( string.find(ed, "^[%p%w%d%s]*$") )

local got = escapeless.dec(ed)
assert( data == got, string.format("wrong\nenc:%s\npre:%s\naft:%s", ed, data, got))
