local apply_subst = require "page_html.util.apply_subst"
local Assets = require "page_html.Assets"

local This = {}
This.__index = This
This.__name = "page_html.html.Suggest"

function This:new(new)
   new = setmetatable(new, self)
   new:init()
   return new
end

function This:init() end

function This:output(state, ...)
   -- It might be used w/o derivation..
   local ld = Assets:new{ where= state.where or self.where }

   state.conf = state.conf or {}
   local pat
   if type(self.repl_pattern) == "function" then
      pat = self:repl_pattern(state)
   elseif type(self.repl_pattern) == "string" then
      pat = self.repl_pattern
   else
      local asset_path = (not state.whole and "parts" .. "/" or "") .. self.name .. ".html"
      pat = ld:load(asset_path)
      assert(pat, string.format([[Couldnt get pattern, was left up to asset that wasnt found.
Asset path: %s
Where: %s]], asset_path, table.concat(ld.where, ";")))
   end

   local alts = { title= "page_html: " .. self.name }
   -- Note: forced to layer them a bit, in case :repl returns a metatable itself.
   local repl = self:repl(state, ...)
   local function index(itself, key)
      local got = repl[key] or ld:load(key)
      rawset(itself, key, got)
      return (got~=nil and got) or alts[key]
   end
   return apply_subst(pat, setmetatable({ page_name = self.name, inject_js=state.inject_js },
                         {__index = index}))
end

function This:repl() return {} end

return This
