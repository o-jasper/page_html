-- Modifies things such that (hopefully) luvit can do it.

local function harness(responder)
   return function(req, res)
      print("CMON", req, res)
      local request = {
         path = function() return req.url end
      }
      local response = {
         addHeader = function(_, a,b)
            res:setHeader(a,b)
            return {
               write = function(_, data)
                  res:finish(data)
               end
            }
         end,
      }
      print("bleep")
      return responder(request, response)
   end
end

return harness
