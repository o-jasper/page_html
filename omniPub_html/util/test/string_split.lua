local split = require "omniPub_html.util.split"
local list = require "omniPub_html.util.list"

local function string_split(str, by) return list(split(str, by)) end

local initial = "a/b/c/d/e/f/g/h/i"

print(table.concat(string_split(initial, "/"), "/"))
assert(table.concat(string_split(initial, "/"), "/") == initial)
