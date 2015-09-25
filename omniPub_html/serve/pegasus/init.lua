local Pegasus = require "pegasus"

local function starter(responder)
   return Pegasus:new():start(responder)
end

return require("omniPub_html.serve.lib.pegasus_like")(starter)
