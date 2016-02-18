-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2
--
-- obtained via http://lua-users.org/wiki/BaseSixtyFour,
-- Modified(2016) putting base-4 inbetween instead of base-2.
--
-- Note: this gsub thing might be silly..

local Public = {}

-- character table string.
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function Public.enc(data)
   -- Converts it into base-4, producing 4.
   return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=1,8,2 do
           r = tostring(b%4) .. r
           b = math.floor(b/4)
        end
        assert(#r == 4 and b == 0, #r)
        return r;  -- Add two zeros for good measure. TODO why?
    end)..'00'):gsub('%d%d?%d?', function(x)  -- read 1 to 3 of them.
        if #x < 3 then return '' end
        local c = 0
        for i=1,3, 1 do  -- Decode base4
           c = 4*c + tonumber(x:sub(i,i))
        end
        return b:sub(c+1, c+1)
    end) .. ({ '', '==', '=' })[#data%3 + 1])
end

-- encoding-file
function Public.enc_file(file, fix)
   local got = io.open(file, "r")
   if got then
      local ret = Public.enc(got:read("*a"), fix)
      got:close()
      return ret
   end
end

-- decoding
function Public.dec(data, fix)
   local data = fix and string.gsub(data, '[^'..b..'=]', '') or data
   assert( string.match(data, "^[" .. b .. "]=?=?"), "Invalid base64 encoding ")

   return (data:gsub('.', function(x)  -- Encode to base-4
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)

        for _ = 1,6,2 do
           r = tostring(f%4) .. r
           f = math.floor(f/4)
        end
        return r;
   end):gsub('%d%d?%d?%d?', function(x)  -- And then "base256"
       if #x < 4 then return '' end
       local c = 0
       for i = 1,4 do
          c = 4*c + tonumber(x:sub(i,i))
       end
       return string.char(c)
   end))
end

return Public
