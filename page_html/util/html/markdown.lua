
--TODO Terrible statefulness monster. (metatables do not solve it as is!)

-- Note about state; `.shield` can shield things from being matched again.
-- ANOTHER way is to simply not have things replacing afterwards.
local default_state = {
   name = "md_top",
}

local function markdown(text, state, sequence)
   local state = state or {}
   state.shielded = state.shielded or {}
   if not getmetatable(state) then
      state = setmetatable(state or {}, {__index = default_state})
   end
   for _, el in ipairs(sequence or state.sequence or {}) do
      local pat, fun = unpack(el)
      text = string.gsub(text, pat, function(...) return fun(state, ...) end)
   end
   return text
end

local function submd(text, state, ...)
   local substate = state.substate
   if type(substate) == "function" then
      local ss = substate(state, ...)
      ss.shielded = state.shielded
      return markdown(text, ss)
   elseif type(substate) == "table" then
      substate.shielded = state.shielded
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
   return function(state, content)
      return surround((tag ~= "code" and submd(content, state)) or content, tag)
   end
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
   italic    = { "%*([^*]*)%*", op_surround("i") },
   underline = { "_([^_]*)_",   op_surround("u") },
   strike    = { "~~([^~]*)~~", op_surround("strike") },
   code = {
      "`([^`]*)`",
      function(state, content)
         state.shielded = state.shielded or {}
         table.insert(state.shielded, surround(content, "code"))
         return string.format("{%%shield %d}", #state.shielded)
      end
   },  -- TODO insufficent!

   -- Note it *shields by* matching everything!
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

   unshield = { "{%%shield ([%d]+)}",
                function(state, num)
                   state.shielded = state.shielded or {}
                   return state.shielded[tonumber(num)]
                end
   }
}

default_state.sequence = { ops.hr, ops.header, ops.list, ops.nd, ops.unshield }
default_state.substate = {
   name = "md_expr",
   sequence ={ ops.code, ops.bold, ops.italic, ops.underline, ops.strike,
               ops.link }
}

default_state.ops = ops

return {markdown, default_state}
