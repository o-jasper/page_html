local apply_subst = require "omniPub_html.util.apply_subst"
local Assets = require "omniPub_html.Assets"

local This = {}
for k, v in pairs(Assets) do This[k] = v end
This.__index = This

This.__name = "omniPub_html.html.Suggest"

function This:output(state, ...)
   state.conf = state.conf or {}
   local pat
   if type(self.repl_pattern) == "function" then
      pat = self:repl_pattern(state)
   elseif type(self.repl_pattern) == "string" then
      pat = self.repl_pattern
   else         
      pat = self:load((not state.whole and "body" .. "/" or "") .. self.name .. ".html")
   end

   local repl = self:repl(state)

   if asset_fun then
      local function index(_, key) return repl[key] or self:load(path) end
      return apply_subst(pat, setmetatable({}, {__index = index}))
   else
      return apply_subst(pat, repl)
   end
end

function This:repl() return {} end

return This
