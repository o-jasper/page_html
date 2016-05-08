--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Simple page, obtained from assets, potentially with substition and asset use.

local apply_subst = require "page_html.util.apply_subst"

local This = require("page_html.Assets"):class_derive{__name="page_html.StaticPage"}

function This:output(args)
   --assert(not self[1] and self.name)
   local name = self[1] or self.name
   local str = self.where and self:load(name) or name

   local tp = self.where and string.match(name, "[.]([%w]+)$")
   tp = ({ js = "text/javascript",
           css = "text/css",
           htm = "text/html",
           html = "text/html",
        })[tp] or "text/html"
   if self.repl == true then
      local function index(_,k) return args[k] or self[k] end
      return apply_subst(str, setmetatable({}, {__index= index})), tp
   else
      return str, tp
   end
end

return This
