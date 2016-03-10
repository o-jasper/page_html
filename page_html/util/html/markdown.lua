
--TODO afaics it isnt as stateful anymore, but the metatables are a bit
--  iffy to follow this way.

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
      local substate = setmetatable({shielded = state.shielded}, {__index=substate})
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

local function shield(state, content)
   state.shielded = state.shielded or {}
   table.insert(state.shielded, content)
   return string.format("{%%shield %d}", #state.shielded)   
end

local function handle_html(state, content, intag, top)
   assert(state)
   local ret = ""
   while true do
      local pre, rest, stop, name, args, cnt =
         string.match(content, "^([^<]*)(<(/?)([%w]+)[%s]*([^>]*)>)()")

      if not pre then -- Nothing found.
         return ret .. content, ""
      else
         ret = ret .. ((top and markdown(pre, state)) or pre)

         if stop ~= "" then  -- Return from one.
            if state.assertive then
               assert(intag == name)
               assert(state.args == "")
            end
            return ret .. rest, string.sub(content, cnt)
         else  -- Get into one.
            local got, left = handle_html(state, string.sub(content, cnt), name)
            content = left
            ret = ret .. rest .. got
         end
      end
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
      function(state, content) return shield(state, surround(content, "code")) end
   },

   -- Note it *shields by* matching everything!
   list = {  -- Hmm this one is a pita.
      "\n([^\n]*)",
      function(state, whole)
         local ws, kind, immediate = string.match(whole, "^([ ]*)([%d]*[*+.]?)([^*+\n]?[^\n]*)")
         local indexed = string.match(kind, "^[%d]+[.]$")

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
            table.insert(state.list, 1, {n=#ws, kind=kind, indexed=indexed})
            ret = ret .. (indexed and "<ol><li>" or "<ul><li>")
         else
            while #state.list > 1 and n > #ws do  -- Lower.
               local indexed = table.remove(state.list, 1).indexed
               n = state.list[1].n
               ret = ret .. (indexed and "</li></ol>" or "</li></ul>")
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
   },

   -- TODO Seems little too it but parsing the whole damn thing.
   html = { "<[%w]+[%s]*[^>]*>.+</[%w]+>",
            function(state, content)
               assert(state)
               return shield(state, handle_html(state, content, nil, true))
            end
   },
}

default_state.sequence = { ops.html,
                           ops.hr, ops.header, ops.list, ops.nd, ops.unshield }
default_state.substate = {
   name = "md_expr",
   sequence ={ ops.code, ops.bold, ops.italic, ops.underline, ops.strike,
               ops.link }
}

default_state.ops = ops

return {markdown, default_state}
