local Public = {}

-- Helps remember front and back portion of hexadeximal string.
function Public.fancy_hex(addr, front_cnt, aft_cnt)
   local front_cnt, aft_cnt = front_cnt or 8, aft_cnt or 4
   return string.format(
      [[<span class="addr_front">%s</span><span class="addr_mid">%s</span><span class="addr_aft">%s</span>]],
      string.sub(addr, 1,front_cnt), string.sub(addr, front_cnt+1,#addr-aft_cnt),
      string.sub(addr, #addr-aft_cnt + 1))
end

return Public
