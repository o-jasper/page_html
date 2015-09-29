local time_instructed = require("html_page.util.text.time").instructed

-- Displays times. `about` is the time involved.
return function(self, state)
   return function(str)
      local about, use_str = string.match(str, "([^|]+)|(.+)")
      if about == "cur" then
         local gettime = require("socket").gettime
         return time_instructed(use_str or str, state, gettime()*1000, self:config())
      else
         return time_instructed(use_str or str, state, self:ms_t(about), self:config())
      end
   end
end
