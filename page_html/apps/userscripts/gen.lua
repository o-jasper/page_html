#!/usr/bin/lua

local ret = require("page_html.apps.userscripts"):new():output{ rest_path=arg[1] }
print(ret)
