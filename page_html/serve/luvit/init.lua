return function(http)
   --local http = require "http"  -- For some reason not allowed here..

   -- Cant seem to load my stuff, no cigar..
   local harness = require "page_html.serve.luvit.harness"

   local function starter(responder)
      return http.createServer(harness(responder)):listen(8080)
   end

   require("page_html.serve.lib.pegasus_like")(starter):start()

   print("stopped?")
end
