local Public = {}

Public.name = "util"

function Public:rpc_js()
   return {
      [".man"]   = require "althist.util.man",
      [".doc"]   = require "althist.util.doc",
      [".pydoc"] = require "althist.util.pydoc",

      [".vid"]   = require "althist.util.mpv",
   }
end

return Public
