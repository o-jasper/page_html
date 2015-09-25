local path = "/home/jasper/.lualibs/"

package.path = package.path .. ";" .. path .. "?.lua;" .. path .. "?/init.lua"
print(package.path)

local http = require "http"

-- Cant seem to load my stuff, no cigar..
local harness = require "OmniPub_html.serve.luvit.harness"

local function starter(responder)
   return http.createServer(harness(responder)):listen(8080)
end
return require("omniPub_html.serve.lib.pegasus_like")(starter)
