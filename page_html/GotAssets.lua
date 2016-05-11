local This = require("page_html.util.Class"):class_derive{ __name="page_html.GotAssets"}

This.Assets = require "page_html.Assets"
function This:init()
   self.assets_arg = self.assets_args or {where = self.where}

   if self.data_dir and self.name then
      -- Place user overrides can go.
      table.insert(self.assets_arg.where, 1,
                   self.data_dir .. "assets/" .. self.name .. "/")
   end

   self.assets = self.Assets:new(self.assets_arg)
end

return This
