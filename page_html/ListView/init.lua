--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local This = {}
function This:new(new)
   new = setmetatable(new or {}, self)
   new:init()
   return new
end
This.__index = This

This.Assets = require "page_html.Assets"
-- This.assets_arg = {where = {"first_dir/", "second_dir/"}}

--This.data_dir = "/some/dir/"
--This.db_file  = This.data_dir .. "history.db"
This.name = "noname"

This.ProduceList = require "Searcher.ProduceList"

function This:init()
   assert(self.assets_arg)
   self.assets = self.Assets:new(self.assets_arg)
   self.lister = self.ProduceList:new{
      Formulator = self.Formulator,
      db         = self.Db:new{ filename = self.db_file }
   }
end

local time_resay = require("page_html.util.text.time").resay

This.table_wid = 3
This.limit = {0, 50}

local html_escape = require "page_html.util.text.html_escape"

function This:el_repl(el, state)
   local ret = { name=self.name, i = state.i, at_i=self.limit[1] + self.limit[2] }
   local function add_ret(list) for k,v in pairs(list) do ret[k] = v end end

   if self.Formulator.values.time then
      local time = el[self.Formulator.values.time]
      local date_nums = os.date("*t", time)
      add_ret{ time_resay=time_resay(state, 1000*time),
               table_wid = self.table_wid,
               resay_colspan=self.table_wid,
               hour_min = os.date("%H:%M", time),
               day_frac = (date_nums.hour*3600 + date_nums.min*60 + date_nums.sec)/864.0
      }
   end

   if el.uri and (not el.title or el.title == "") then
      add_ret{ linked_title = string.format([[(<a href="%s">%s</a>)]], el.uri, el.uri),
               ensure_title = "(" .. html_escape(el.uri) .. ")" }
   else
      add_ret{ linked_title =
                  string.format([[<a href="%s">%s</a>]], el.uri, html_escape(el.title)),
               ensure_title = html_escape(el.title) }
   end

   for k,v in pairs(el) do ret[k] = html_escape(v) end

   return ret
end

local apply_subst = require "page_html.util.apply_subst"

function This:el_html(el, state)
   return apply_subst(self.assets:load("parts/" .. self.name .. ".el.htm"),
                      self:el_repl(el, state))
end

function This:list_html_list(list, state, si)
   local ret, state = {}, state or {}
   for i, el in ipairs(list) do
      state.i = (si or 0) + i
      table.insert(ret, self:el_html(el, state))
   end
   return ret
end

function This:list_html(...) return table.concat(self:list_html_list(...), "\n") end

function This:form(...) return self.lister:form(...) end

function This:exec_form(form)
   form:finish()
   return self.lister.db:exec(form:sql_pattern(), unpack(form:sql_values()))
end

function This:repl(args)
   local _form, _list  -- Hmm, memoized too much work this way.
   local function form()
      _form = _form or self:form(nil, args)
      return _form
   end
   local function list()
      if not _list then
         _list = self:exec_form(form())
      end
      return _list
   end
   return {
      name = self.name, title = self.name,
      list = function() return self:list_html(list()) end,
      cnt  = #list(),
      sql  = function() return form():sql() end
   }
end

This.page_path = "page/list.htm"

function This:output(...)
   return apply_subst(self.assets:load(self.page_path), self:repl(...))
end

local StaticPage = require "page_html.StaticPage"

function This:static_list(set)
   local ret = {}
   for k,v in pairs(set) do
      if v == true then v = {} end
      v.where = self.where
      v.name = k
      table.insert(ret, StaticPage:new(v))
   end
   return ret
end

function This:extra_list()
   return self:static_list{
      ["css/style.css"]    = true,
      ["css/ListView.css"] = true,
      ["js/common.js"]     = true,
      ["js/manual_sql.js"] = true,
      ["js/page.js"]   = true,
      ["js/data.js"]   = {repl=true,
                          at_i = self.limit[2], search_term="", step_cnt=3,
                          table_wid=self.table_wid},
   }
end

local function list_html_rawdata(list, pattern, m, sn)
   if #list == 0 then return {} end

   local ret, ksort = {}, {}
   for k in pairs(list[1]) do table.insert(ksort, k) end
   table.sort(ksort)

   local raw_1 = [[<td class="raw"><span class="rawkey">{%key}</span>:<span class="rawval">{%val}</span></td>]]

-- self.assets:load("parts/raw.el.1.htm")

   for i,el in ipairs(list) do
      local n, parts = sn or 2, {{}}
      for _, k in ipairs(ksort) do
         table.insert(parts[1], apply_subst(raw_1, {key=k, val=el[k]}))
         n = n + 1
         if n == m then
            table.insert(parts, 1, {})
            n = 1
         end
      end
      local repl = { i = i,
                     first = table.concat(table.remove(parts)),
      }

      local rest_parts = {}
      for _, el in ipairs(parts) do table.insert(rest_parts, table.concat(el)) end
      repl.rest = table.concat(rest_parts, "</tr><tr>")
      
      table.insert(ret, apply_subst(pattern, repl))
   end
   return ret
end

This.rpc_sql_enabled = true

function This:search(search_term, state)
   local form = self:form(search_term, state)
   local list = self:exec_form(form)

   return self:list_html_list(list, state, state.limit[1]), form:sql()
end

function This:rpc_js()
   return {  -- Produces a bunch of results.
      rpc_search = function(...) return {self:search(...)} end,
      rpc_sql = function(sql_code)
         if self.rpc_sql_enabled then
            local pattern = self.assets:load("parts/raw.el.htm")
            local list = self.lister.db:exec(sql_code)
            return list_html_rawdata(list, pattern, self.table_wid)
         end
      end,
   }
end

return This
