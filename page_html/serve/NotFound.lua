--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local This = require("page_html.util.Class"):class_derive{
   name="page_not_found.html", __name="page_html.server.NotFound"}

This.where = { "page_html/serve/" }
This.Assets = require "page_html.Assets"

function This:init()
   self.asset_arg = self.asset_arg or { where = self.where }
   self.assets = self.Assets:new(self.asset_arg)
end

function This:repl(args)
   local self_list, args_list, page_list, extra_page_list = {}, {}, {}, {}
   for k, v in pairs(self) do
      table.insert(self_list, string.format("<tr><td>%s</td><td>=</td><td>%s</td></tr>", k,v))
   end
   for k, v in pairs(args) do
      table.insert(args_list, string.format("<tr><td>%s</td><td>=</td><td>%s</td></tr>", k,v))
   end
   -- TODO separate principle and secondary pages, show descriptions.
   for k, v in pairs(self.pages) do
      local val = v.name == k  and v.name or string.format("%s != %s", k, v.name)
      local htm = string.format([[<tr><td><a href="/%s/">%s</a></td></tr>]],
                      val, val)
      table.insert(v.extra and extra_page_list or page_list, htm)
   end

   return {
      missing_page_name = string.match(args.path or "", "^([^/]*)/?"),
      self_list = table.concat(self_list, "\n"),
      args_list = table.concat(args_list, "\n"),
      page_list = table.concat(page_list, "\n"),
      extra_list = table.concat(extra_page_list, "\n"),
   }
end

local apply_subst = require "page_html.util.apply_subst"
function This:output(...)
   for k,v in pairs(self.assets.where) do print(k,v) end
   return apply_subst(self.assets:load("page_not_found.html"), self:repl(...))
end

return This
