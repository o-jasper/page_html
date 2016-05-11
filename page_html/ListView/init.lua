--  Copyright (C) 05-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local GotAssets = require "page_html.GotAssets"
local This = GotAssets:class_derive{__name="ListView", name="ListView"}

This.ProduceList = require "Searcher.ProduceList"

function This:init()
   GotAssets.init(self)

   assert(self.data_dir, "Don't know where to put the files.")
   self.db_file = self.db_file or (self.data_dir .. "main.db")

   self.lister = self.ProduceList:new{
      Formulator = self.Formulator,
      db         = self.Db:new{ filename = self.db_file }
   }
end

local text_time = require "page_html.util.text.time"

This.table_wid = 3
This.limit = {0, 50}

local html_escape = require "page_html.util.text.html_escape"

This.list_el_nameprep = "list_el_"

local function namesys(_, str)
   return string.format([[id="{%%list_el_nameprep}{%%i}_%s"]], str)
end

local apply_subst = require "page_html.util.apply_subst"

function This:el_repl(el, state)
   local ret = { name=self.name, i = state.i, at_i=self.limit[1] + self.limit[2] }
   local function add_ret(list) for k,v in pairs(list) do ret[k] = v end end

   -- Time stuff.
   if self.Formulator.values.time then
      local time = el[self.Formulator.values.time]
      local date_nums = os.date("*t", time)
      add_ret{ time_resay = text_time.resay(state, 1000*time),
               table_wid = function(x) return self.table_wid + (tonumber(x) or 0) end,
               resay_colspan = self.table_wid,
               hour_min = os.date("%H:%M", time),
               day_frac = (date_nums.hour*3600 + date_nums.min*60 + date_nums.sec)/864.0,
               date = function(_, inp) return os.date(inp, time) end,
               date_min = function()
                  return text_time.mention_change(os.date("*t"), time)
               end,
      }
   end

   add_ret{
      list_el_nameprep = (el.list_el_name or self.list_el_nameprep),
      namesys = namesys,
      selectme = [[id="el_{%i}" onclick="select_list_index({%i})"]],
   }

   if el.uri and (not el.title or el.title == "") then
      add_ret{ linked_title = [[(<a {%namesys linked_title} href="{%uri}">{%uri}</a>)]],
               ensure_title = "(" .. html_escape(el.uri) .. ")" }
   else
      add_ret{ linked_title = [[<a {%namesys linked_title} href="{%uri}">{%title}</a>]],
               ensure_title = html_escape(el.title) }
   end

   -- Add direct values.
   for k,v in pairs(el) do ret[k] = html_escape(v) end

   -- Base on other page objects.
   ret.insert_page_method = function(_, name, method, ...)  -- Method provided by page.
      local page = self.server.pages[name]
      return page and page[method] and page[method](page, el, ...) or " "
   end
   ret.insert_page = function(_, name, ...)  -- Insert entire page.
      return ret.insert_page_method(name, "output", el, ...)
   end

   add_ret{ start = "<!-- start {%i} -->",  ["end"] ="<!-- end {%i} -->" }

   -- Was in raw first, sorts the keys so can show them.
   local ksort = {}
   for k in pairs(el) do table.insert(ksort, k) end
   table.sort(ksort)

   local raw_1 = [[<td class="raw"><span class="rawkey">{%key}</span>:<span class="rawval">{%val}</span></td>]]
   local n, parts = 2, {{}}
   for _, k in ipairs(ksort) do
      table.insert(parts[1], apply_subst(raw_1, {key=k, val=el[k]}))
      n = n + 1
      if n == m then
         table.insert(parts, 1, {})
         n = 1
      end
   end
   ret.raw_first = table.concat(table.remove(parts))

   local rest_parts = {}
   ret.raw_rest = function()
      if #rest_parts == 0 then
         for _, el in ipairs(parts) do table.insert(rest_parts, table.concat(el)) end
      end
      return table.concat(rest_parts, "</tr><tr>")
   end

   ret.delete = [[<button hidden=true {%namesys del}
onclick="gui_delete({%i}, {%id});">&#10007;</button>]]

   ret.edit = [[<button hidden=true {%namesys edit}
onclick="gui_edit({%i}, {%id});">&#9999;</button>]]

   ret.modify = ret.delete .. ret.edit

   ret.modify_place = [[<span id="el_mod_{%i}"></span>]]

   return ret
end

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

   local ret = {
      name = self.name, title = self.name,
      list = function() return self:list_html(list()) end,
      cnt  = #list(),
      sql  = function() return form():sql() end,
      rest_path = " ",  -- Rest path _cared to share_ (defaultly: dont care to share)

   -- Base on other pages.
      insert_page_method = function(name, method, ...)  -- Method provided by page.
         local page = self.server.pages[name]
         return page and page[method] and page[method](page, ...) or " "
      end,
   }

   ret.insert_page = function(name, ...)  -- Insert entire page.
      return ret.insert_page_method(name, "output", ...)
   end

   ret.script = function(_, file)
      return [[<script type="text/javascript" src="/{%name}/]] .. file .. [["></script>]]
   end
   ret.css = function(_, file)
      return [[<link rel="stylesheet" href="/{%name}/]] .. file .. [[">]]
   end

   return ret
end

This.page_path = "page/list.htm"

This.assets_served = {
   ["css/style.css"]    = true,
   ["css/ListView.css"] = true,
   ["js/common.js"]     = true,
   ["js/manual_sql.js"] = true,
   ["js/page.js"]   = true,
   ["js/init.js"]   = true,
   ["js/init_list.js"]   = true,
}

function This:data_js_repl()
   return {
      sql_enabled = tostring(self.rpc_enabled.rpc_sql),

      repl=true, list_el_nameprep=self.list_el_nameprep,
      at_i = self.limit[2], search_term="", step_cnt=50,
      table_wid=self.table_wid,

      edit_html = string.gsub(self.assets:load("parts/make_bookmark.htm") or "",
                              "([^\n]+)\n", function(x) return x .. " " end),
   }
end

function This:output(args, ...)
   local rp = args.rest_path
   if self.assets_served[rp] then
      return self.assets:load(rp), "text/" .. string.match(rp, "[.]([^.]+)$")
   elseif rp == "js/data.js" then
      local ret = apply_subst(self.assets:load(rp), self:data_js_repl())
      return ret, "text/javascript"
   else
      return apply_subst(self.assets:load(self.page_path), self:repl(args, ...))
   end
end

function This:search(search_term, state)
   local form = self:form(search_term, state)
   local list = self:exec_form(form)

   return self:list_html_list(list, state, state.limit[1]), form:sql()
end

This.rpc_enabled = {
   rpc_search = true,
   rpc_sql = false,
   delete_id = true,
   get_id = true,
   update_id = true,
}
This.rpc_delete_enabled = true
This.rpc_get_id_enabled = true

function This:rpc_js()
   local really, ret = {}, {
      rpc_search = function(...) return {self:search(...)} end,
      rpc_sql = function (sql_code)
         local html_list = {}
         local list, state = self.lister.db:exec(sql_code), {}
         for i, el in ipairs(list) do
            local repl = self:el_repl(el, state)
            repl.i = i
            table.insert(html_list,
                         apply_subst(self.assets:load("parts/raw.el.htm"), repl))
         end
         return html_list
      end,
      delete_id = function(id)
         if self.rpc_delete_enabled and type(id) == "number" then
            self.lister.db:delete(id)
         end
      end,
      get_id = function(id) return self.lister.db:get_id(id) end,
      update_id = function(data) self.lister.db:alter_entry(data) end,
   }
   for k,v in pairs(self.rpc_enabled) do
      really[k] = v and ret[k] or nil
   end
   return really
end

return This
