local split = require "page_html.util.split"
local list = require "page_html.util.list"

local function string_split(str, by) return list(split(str, by)) end

local initial = "a/b/c/d/e/f/g/h/i"

print(table.concat(string_split(initial, "/"), "/"))
assert(table.concat(string_split(initial, "/"), "/") == initial)
