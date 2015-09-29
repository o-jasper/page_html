-- Replacement stuff.

return {
   dateText = function(self) return os.date("%c", self:ms_t()/1000) end,
   -- TODO tad primitive...
   dateHTML = "{%dateText}",
   
   dayname = function(self) return html.day_names[datetab(self:ms_t()).wday] end,
   monthname = function(self) return html.day_names[datetab(self:ms_t()).wday] end,
   
   -- NOTE: the delta/resay cases only make sense when sorting by time.
   -- TODO: perhaps the state/state.config should tell This and have proper behavior.
   delta_dateHTML = function(self, state)
      return html.delta_dateHTML(state, self:ms_t())
   end,
   
   timemarks = function(self, state)
      return html.time(state, self:ms_t())
   end,
   
   resay_time = function(self, state)
      return html.resay_time(state, self:ms_t(), (state.conf.resay or {}).long)
   end,
   
   short_resay_time = function(self, state)
      local config = (state.conf.resay or {}).short or {
         {"year", "Year {%year}"},
         {"yday", "{%month}/{%day} {%short_dayname}"},
         init = " ", nochange = " ", }
      return html.resay_time(state, self:ms_t(), config)
   end,
}
