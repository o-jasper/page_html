local This = require("page_html.util.Class"):class_derive{ __name="page_html.GotAssets"}

This.Assets = require "page_html.Assets"
function This:init()
   self.assets_arg = self.assets_args or {where = self.where}
   self.assets = self.Assets:new(self.assets_arg)
end

return This
