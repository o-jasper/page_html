local http = require "http"

local function harness(responder)
   return function(req, res)
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
      return request, response
   end
end
