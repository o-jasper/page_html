--  Copyright (C) 15-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ListView = require "page_html.ListView"

local This = {}
for k,v in pairs(ListView) do This[k] = v end
This.__index = This

This.thread_name = "uri"  -- Note: wont be good enough..

function This:select_thread(form, el)
   form:equal_1(self.thread_name, el[self.thread_name])   
end

function This:el_repl(el, state)
   local ret = ListView.el_repl(self, el, state)
   local alt = getmetatable(ret).__index

   alt.subthread = function()
      if state.thread_depth < self.max_thread_depth then
         -- NOTE: complete sub instance
         local sub = (self.SubInstance or getmetatable(self)):new()
         local form = sub.lister:form(state.search_term, state)
         -- _Add_ the requirement of being in the thread.
         --  i.e. the lister should already have selected the comments "worthy of seeing"
         self:select_thread(form, el)
         form:finish()
         local list = sub.lister.db:exec(form:sql_pattern(), unpack(form:sql_values()))

         -- Things are marked in the state in here too.(each entry once)
         return sub:list_html(list, state)
      else
         return "{%max_depth_reached}"
      end
   end

   return ret
end

local apply_subst = require "page_html.util.apply_subst"

function This:el_html(el, state)
   -- `done_element_ids` keeps track of what has already been done in the sub-threads.
   state.done_element_ids = state.done_element_ids or {}
   state.thread_depth = state.thread_depth or 0
   if state.done_element_ids[el.id] then  -- Skip if already done.
      return ""
   else  -- Do the node.
      state.done_element_ids[el.id] = true
      return apply_subst(self.assets:load("parts/" .. self.name .. ".el.htm"),
                         self:el_repl(el, state))
   end
end

return This