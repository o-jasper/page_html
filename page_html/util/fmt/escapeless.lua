-- The idea is that all potentially harmful characters are excluded, instead of
-- relying on SQL escaping.
--
-- Preferably, SQL globbing still works.
-- Current idea: any double uppercase is arbitrary binary. Should do that.

-- Not punctuation, lowercase, digits or space.

-- Before Q, "hex", Q is the escape, rest unused.
local num = "ABCDEFGHIJKLMNOP"
local esc = "_"
local order = num .. esc
assert( #order == 17, #order)

-- Encode/decode   -- TODO
--   [num or used]  <-> _[]
--   nonprintable   <-> [num][num] 

-- Escapes stuff.
local esc_gsub_str = "[" .. num .. esc .. "]"
local function esc_gsub(x)  -- Marks doubles that are _not_ involved.
   return esc .. x
end

-- Encodes stuff.
local enc_gsub_str = "[^%w%d%s,.?!@#$&{}_]"
local function enc_gsub(x)  -- Replaces with data variant.
   local v = string.byte(x)
   local i, j = 1 + v%16, 1 + math.floor(v/16)
   return string.sub(order, i,i) .. string.sub(order, j,j)
end

local function enc(data)
   local data = string.gsub(data, esc_gsub_str, esc_gsub)
   return string.gsub(data, enc_gsub_str, enc_gsub)
end

local dec_gsub_str = "[" .. esc .. num .. "][" .. esc .. num .. "]"
local function dec_gsub(x)
   local first, second = string.sub(x,1,1), string.sub(x, 2,2)
   if first == "_" then -- De-escape.
      return second
   else  -- Decode.
      local c = string.find(order, first,1, true) +
                16*string.find(order, second,1, true) - 17
      return string.char(c)
   end
end

local function dec(str)
   return string.gsub(str, dec_gsub_str, dec_gsub)
end

return { enc=enc, dec=dec }
