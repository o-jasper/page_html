local function html_list(list, state)
   local ret = {}
   for i, info in ipairs(list) do
      assert(info.output, "one of the info object did not have a :html method")
      table.insert(ret, info:output())
   end
   return ret
end

return function(list, info)
   return {
      cnt       = #list,
      html_list = info.html_list and html_list(list, info),
      list      = info.list and list,
   }
end
