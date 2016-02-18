local base64 = require "page_html.util.fmt.base64"

assert(base64.chars == 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/')

local fd = io.open("/dev/stdin")

local data = fd:read("*a")
local ed = base64.enc(data)

assert(string.find(ed, "^[%w+/]*=?=?$"), ed)

assert(data == base64.dec(ed))  -- Bijection test.

print(ed)
