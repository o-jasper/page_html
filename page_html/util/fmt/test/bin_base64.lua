local base64 = require "page_html.util.fmt.base64"

local fd = io.open("/dev/stdin")

local data = fd:read("*a")
local ed = base64.enc(data)

assert(data == base64.dec(ed))  -- Bijection test.

print(ed)
