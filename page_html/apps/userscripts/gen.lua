#!/usr/bin/lua
local data_dir = "/home/jasper/iso/newiso/page_html_set/page_html/.page_html/data/"
local us = require("page_html.apps.userscripts"):new{
   data_dir=data_dir, port=(tonumber(arg[2]) or 9090)}
local ret = us:output{ rest_path=arg[1] }
print(ret)
