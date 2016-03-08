
local function surround(content, with)
   return string.format("<%s>%s</%s>", with, content, with)
end

local ops = {}

local function markdown(text, state, sequence)
   --local state = state or { order="GOT NOTHING"}
   for _, el in ipairs(sequence or state.sequence or {}) do
      local pat, fun = unpack(el)
      if type(fun) == "function" then
         text = string.gsub(text, pat, function(...) return fun(state, ...) end)
      else
         text = string.gsub(text, pat, fun)
      end
   end
   return text
end

local function submd(text, state, ...)
   return markdown(text, state.substate and state:substate(...) or state)
end

ops = {
   hr = { "\n%-%-%-+\n", "\n<hr>\n" },
   header = {
      "\n(##?#?#?#?)[%s]*([^\n]+)\n",
      function(state, leveltxt, content)
         return string.format("\n<h%d>%s</h%d>\n",
                              #leveltxt, submd(content, state), #leveltxt)
      end
   },
   link = {
      "%[([^%]]+)%]%(([^)]+)%)",
      function(state, content, link)
         return string.format([[<a href="%s">%s</a>]], link, submd(content, state))
      end
   },
   -- Decoration(as set)
   decs = {
      "([*_~]+)([^*_~]+)([*_~]+)",
      function(state, before, content, after)
         local content = submd(content, state)
         assert(not state.assertive or before == string.reverse(after))
         if not state.ifmatch or before == string.reverse(after) then
            if string.find(before, "**", 1, true) then
               content = surround(content, "b")
            elseif string.find(before, "*", 1, true) then
               content = surround(content, "i")
            end
            if string.find(before, "_", 1, true) then
               content = surround(content, "u")
            end
            if string.find(before, "~~", 1, true) then
               content = surround(content, "strike")
            end
         end
         return content
      end
   },

   list = {  -- Hmm this one is a pita.
      "\n([ ]*)([*+]?)([^*+\n]?[^\n]*)",
      function(state, ws, kind, immediate)

         if not kind or kind ~= "" then ws = ws .. "  " end
         state.list = state.list or {{n=0, kind=""}}
         local n, code_mode = state.list[1].n, state.code_mode
         -- Code mode and going in/out.
         state.code_mode = (#ws - n >= 3)
         local ret = string.rep(" ", n/2)
         if state.code_mode then
            if not code_mode then ret = "<pre>" end
            return ret .. immediate .. "\n"
         elseif code_mode then  -- Just went off.
            ret = "</pre>\n"
         end

         -- List depth changes.
         if n < #ws and kind ~= "" then  -- Deeper.
            table.insert(state.list, 1, {n=#ws, kind=kind})
            ret = ret .. "<ul><li>"
         else
            while #state.list > 1 and n > #ws do  -- Lower.
               table.remove(state.list, 1)
               n = state.list[1].n
               ret = ret .. "</li></ul>\n"
            end
            -- New list elements.
            if kind ~= "" then
               ret = ret .. "</li><li>"
            end
         end

         -- Finally stuff in the markdowned immediate.
         return ret .. submd(immediate, state) .. "\n"
      end
   },

   -- No double or more newlines.
   nd = { "\n+", function() return "\n" end },
}

local default_state = {
   ops = ops,
   sequence = { ops.hr, ops.header, ops.list, ops.nd },
   substate = function(state) return { sequence ={ ops.decs, ops.link } } end
}

local function export_markdown(text, state)
   state = state or {}
   for k, v in pairs(default_state) do state[k] = state[k] or v end
   return markdown("\n" .. text .. "\n", state)
end

return {export_markdown, ops, markdown}
