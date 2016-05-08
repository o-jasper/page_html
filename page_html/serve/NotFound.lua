--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local StaticPage = require "page_html.StaticPage"
local This = StaticPage:class_derive{name="page_not_found", __name="page_html.server.NotFound"}

This.repl = true
This[1] = [[
Dont have this..<h4>args:</h4>
<table>{%list}</table>
<h4>Dont have page <code>{%page_name}</code>, to have pages:</h4>
<table>{%page_list}</table>
]]

function This:init()
   StaticPage:init(self)
   local list, page_list = {}, {}
   for k, v in pairs(self) do
      table.insert(list, string.format("<tr><td>%s</td><td>=</td><td>%s</td></tr>", k,v))
   end
   for k, v in pairs(self.pages) do
      local val = v.name == k  and v.name or string.format("%s != %s", k, v.name)
      table.insert(page_list,
                   string.format([[<tr><td><a href="/%s/">%s</a></td></tr>]],
                      val, val))
   end
   self.list = table.concat(list, "\n")
   self.page_list = table.concat(page_list, "\n")
end

return This
