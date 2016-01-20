local Public = {}

-- Functions helping out in writing time as text/html.
function Public.delta_t(dt, pre, aft)  -- TODO tad messy..
   pre, aft = pre or "", aft or ""
   local adt = math.abs(dt)
   local s, min, h, d = 1000, 60000, 3600000, 24*3600000
   if adt < s then  -- milliseconds
      return string.format("%d%sms%s", dt, pre, aft)
   elseif adt < 10*s then  -- ~ 1s
      return string.format("%g%ss%s", math.floor(10*dt/s)/10, pre, aft)
   elseif adt < min then -- seconds
      return string.format("%d%ss%s", math.floor(dt/s), pre, aft)
   elseif adt < 10*min then -- ~ 1 min
      return string.format("%g%s min%s", math.floor(10*dt/min)/10, pre, aft)
   elseif adt < h then -- minutes
      return string.format("%d%smin%s", math.floor(dt/min), pre, aft)
   elseif adt < 10*h then -- ~1 hour
      return string.format("%g%s hours%s", math.floor(10*dt/h)/10, pre, aft)
   elseif adt < 3*d then -- hours
      return string.format("%d%shours%s", math.floor(dt/h), pre, aft)
   elseif adt < 10*d then -- ~ day
      return string.format("%g%sdays%s", math.floor(10*dt/d)/10, pre, aft)
   else
      return string.format("%g%sdays%s", math.floor(dt/d), pre, aft)
   end
end

function Public.delta(state, ms_t)
   local ret = ""
   if not state.last_time then
      ret = os.date(nil, math.floor(ms_t/1000))
   else
      local datecfg = (state.config or {}).date or {}
      ret = Public.delta_t(ms_t - state.last_time, datecfg.pre, datecfg.aft)
   end
   state.last_time = ms_t
   return ret
end 

function Public.marks(state, ms_t)
   local tm = state.timemarks
   if not tm then
      state.timemarks = os.date("*t", math.floor(ms_t/1000))
      return ""
   end
   local str, d = "", os.date("*t", math.floor(ms_t/1000))
   local timemarks = state.config.timemarks or
      {{"year", "Y"}, {"month", "M"}, {"yday", "d"},
       {"hour", "h"}, {"min", "<small>m</small>"}}
   for _, el in pairs(timemarks) do -- Things we care to mark.
      local k, v = el[1], el[2]
      -- If that aspect of the date is no longer the same, increament it.
      if d[k] ~= tm[k] then
         if v then str = str .. v end  -- If want a string.
         -- TODO for instance, a horizontal line instead.
         tm[k] = d[k]
      end
   end
   return str
end

Public.day_names = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday",
                    "Saturday"}
Public.short_day_names = {"Sun", "Mon", "Tue", "Wed", "Th", "Fri",
                          "Sat"}
Public.month_names = {"Januari", "Februari", "March", "April", "May",
                      "June", "Juli", "Augustus", "September", "October",
                      "November", "December"}
Public.short_month_names = {"Jan", "Feb", "Mar", "Apr", "May",
                            "June", "Juli", "Aug", "Sep", "Oct",
                            "Nov", "Dec"}

function Public.additional_time_strings(d)
   d.dayname       = Public.day_names[d.wday]
   d.short_dayname = Public.short_day_names[d.wday]
   d.monthname       = Public.month_names[d.month]
   d.short_monthname = Public.short_month_names[d.month]
   return d
end

function Public.resay(state, ms_t, dontupdate)
   local tm = state.resay_timemarks
   local timemarks = (state.config or {}).timemarks or
      { {"year", [[<<tr><td colspan="{%resay_colspan}"><span class="year_change">Newyear {%year}<br><hr></span></td></tr>]]},
         {"yday", [[<tr><tr><td colspan="{%resay_colspan}"><span class="day_change">{%dayname} {%day}
{%monthname}<br><hr></span></td></tr>]]},
        --{"hour", [[</tr><tr><td class="hour_change">at {%hour}:{%min}</td>]]},
        init = " ", nochange = " ",
      }
   
   if not tm then
      state.resay_timemarks = os.date("*t", math.floor(ms_t/1000))
      return timemarks.init
   end
   local d = os.date("*t", math.floor(ms_t/1000))
   for _, el in pairs(timemarks) do -- Things we care to mark.
      local k, pattern = el[1], el[2]
      -- If that aspect of the date is no longer the same, increment it.
      if d[k] ~= tm[k] then
         if not dontupdate then tm[k] = d[k] end
         return string.gsub(pattern, "{%%([_./%w]+)}", Public.additional_time_strings(d))
      end
   end
   return timemarks.nochange
end

local function index_fun(frompub, fromdate)
   return function(state, ms_t)
      return Public[frompub][os.date("*t", ms_t/1000)[fromdate]]
   end
end

Public.dayname       = index_fun("day_names",  "wday")
Public.short_dayname = index_fun("short_day_names", "wday")

Public.monthname       = index_fun("month_names", "month")
Public.short_monthname = index_fun("short_month_names", "month")

local disallowed = {}

Public.instruct_alt = {
   raw = function(_, ms_t)
      return tostring(math.floor(ms_t / 1000 + 0.5))
   end,
   day    = Public.dayname,  sday = Public.short_dayname,
   month = Public.monthname, smonth = Public.short_monthname,
}

local translate = { hour="%H", min="%M", sec="%S", day_n="%w", month_n="%m" }
for k,v in pairs(translate) do
   Public.instruct_alt[k] = function(_, ms_t) return os.date(v, math.floor(ms_t/1000)) end
end

function Public.instructed(instruction, state, ms_t, dontupdate)
   instruction = instruction or "%c"
   assert(type(instruction) == "string", instruction)
   local key = string.match(instruction, "[%w_]+")
   local got = Public[key] or Public.instruct_alt[key]
   if key and not disallowed[key] and got then
      return got(state, ms_t, dontupdate)
   else
      return os.date("%" .. key)
   end
end

return Public
