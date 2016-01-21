local This = {}
function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end
This.__index = This

This.Assets = require "page_html.Assets"
-- This.assets_arg = {where = {"althist/history/"}}

-- TODO absolute..
--This.data_dir = "/home/jasper/iso/firefox/userscript/althist/data/"
--This.db_file  = This.data_dir .. "history.db"
This.name = "noname"

function This:init()
   self.assets = self.Assets:new(self.assets_arg)
   self.lister = require("Searcher.ProduceList"):new{
      Formulator = self.Formulator,
      db         = self.Db:new{ filename = self.db_file }
   }
end

local time_resay = require("page_html.util.text.time").resay

This.table_wid = 3
This.limit = {0, 50}

function This:el_repl(el, state)
   local alt = { i = state.i, at_i=self.limit[1] + self.limit[2] }
   local function add_alt(list) for k,v in pairs(list) do alt[k] = v end end

   if self.Formulator.values.time then
      local time = el[self.Formulator.values.time]
      local date_nums = os.date("*t", time)
      add_alt{ time_resay=time_resay(state, 1000*time), resay_colspan=self.table_wid,
               hour_min = os.date("%H:%M", time),
               day_frac = (date_nums.hour*3600 + date_nums.min*60 + date_nums.sec)/864.0
      }
   end

   if el.uri and (not el.title or el.title == "") then
      add_alt{ linked_title = string.format([[(<a href="%s">%s</a>)]], el.uri, el.uri),
               ensure_title = "(" .. el.uri .. ")" }
   else
      add_alt{ linked_title = string.format([[<a href="%s">%s</a>]], el.uri, el.title),
               ensure_title = el.title }
   end
   return setmetatable(el, {__index = alt})
end

local apply_subst = require "page_html.util.apply_subst"

function This:el_html(el, state)
   return apply_subst(self.assets:load("parts/" .. self.name .. ".el.htm"),
                      self:el_repl(el, state))
end

function This:list_html_list(list, si)
   local ret, state = {}, {}
   for i, el in ipairs(list) do
      state.i = (si or 0) + i
      table.insert(ret, self:el_html(el, state))
   end
   return ret
end

function This:list_html(...) return table.concat(self:list_html_list(...), "\n") end

function This:repl()
   local list = self.lister:produce()
   return {
      name  = self.name, title = self.name,
      list  = self:list_html(list),
      cnt = #list,
   }
end

function This:output(...)
   return apply_subst(self.assets:load("page/list.htm"), self:repl(...))
end


local StaticPage = require "page_html.StaticPage"

function This:static_list(set)
   local ret = {}
   for k,v in pairs(set) do
      v.where = self.where
      v.name = k
      table.insert(ret, StaticPage:new(v))
   end
   return ret
end

function This:extra_list()
   return self:static_list{
      ["style.css"]    = {"style.css"},
      ["js/common.js"] = {"js/common.js"},
      ["js/page.js"]   = {"js/page.js", at_i = self.limit[2], search_term="", step_cnt=3},
   }
end

function This:js()
   return {  -- Produces a bunch of results.
      rpc_search = function(search_term, state, limit)
         local limit = limit or self.limit
         local list = self.lister:produce(search_term, state, limit)
         return self:list_html_list(list, self.limit[1])
      end,
   }
end

return This
