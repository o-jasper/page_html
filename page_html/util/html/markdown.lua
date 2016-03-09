
local function markdown(text, state, sequence)
   for _, el in ipairs(sequence or state.sequence or {}) do
      local pat, fun = unpack(el)
      text = string.gsub(text, pat, function(...) return fun(state, ...) end)
   end
   return text
end

local function submd(text, state, ...)
   local substate = state.substate
   if type(substate) == "function" then
      return markdown(text, substate(state, ...))
   elseif type(substate) == "table" then
      return markdown(text, substate)
   elseif substate == false then
      return text
   else
      return markdown(text, state)
   end
end

local function surround(content, with)
   return string.format("<%s>%s</%s>", with, content, with)
end

local function op_surround(tag)
   return function(state, content) return surround(submd(content, state), tag) end
end

local ops = {
   hr = { "\n%-%-%-+\n", function() return "\n<hr>\n" end },
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
   bold      = { "%*%*([^*]*)%*%*", op_surround("b") },
   italic   = { "%*([^*]*)%*",  op_surround("i") },
   underline = { "_([^_]*)_",   op_surround("u") },
   strike    = { "~~([^~]*)~~", op_surround("strike") },
   code      = { "`([^`]*)`",   op_surround("code") },  -- TODO insufficent!

   -- Note, can do what it can because it covers everything. A `code` isnt yet implemented..
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
   name = "md_top",
   ops = ops,
   sequence = { ops.hr, ops.header, ops.list, ops.nd },
   substate = {
      name = "md_expr",
      sequence ={ ops.bold, ops.italic, ops.underline, ops.strike,
                  ops.code, ops.link }
   },
}

local function export_markdown(text, state)
   state = state or {}
   for k, v in pairs(default_state) do state[k] = state[k] or v end
   return markdown("\n" .. text .. "\n", state)
end

return {export_markdown, ops, markdown}
