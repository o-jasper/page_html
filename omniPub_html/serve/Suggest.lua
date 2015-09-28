local apply_subst = require "omniPub_html.util.apply_subst"
local Assets = require "omniPub_html.Assets"

local This = {}
for k, v in pairs(Assets) do This[k] = v end
This.__index = This

This.__name = "omniPub_html.html.Suggest"

function This:output(state, ...)
   -- It might be used w/o derivation..
   local ld = (self.load and self) or Assets:new{ where= state.where or self.where }

   state.conf = state.conf or {}
   local pat
   if type(self.repl_pattern) == "function" then
      pat = self:repl_pattern(state)
   elseif type(self.repl_pattern) == "string" then
      pat = self.repl_pattern
   else
      local asset_path = (not state.whole and "body" .. "/" or "") .. self.name .. ".html"
      pat = ld:load(asset_path)
      assert(pat, string.format([[Couldnt get pattern, was left up to asset that wasnt found.
Asset path: %s]], asset_path))
   end

   -- Note: forced to layer them a bit, in case :repl returns a metatable itself.
   local repl = self:repl(state, ...)
   local function index(itself, key)
      local got = repl[key] or ld:load(key)
      rawset(itself, key, got)
      return got
   end
   return apply_subst(pat, setmetatable({ page_name = self.name }, {__index = index}))
end

function This:repl() return {} end

return This
