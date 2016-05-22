-- Keep git repos corresponding to the web.

return function(info, uri, ...)
   -- TODO add others.
   local got = string.match(uri, "^https?://(github[.]com/[%w-_.]+/[%w-_.]+)/?") or
      string.match(uri, "^[%w-+]+://([%w-_+./]+[.]git)$")

   if got then
      local git_dir = info.server.git_dir or
         (info.server.pages.history.data_dir .. "/localized/")
      local dir, final = string.match("^(.+)/([^/]+)")
      local to_dir = git_dir .. dir
      exec([[mkdir -p "%s"]], to_dir)
      -- TODO just set remote?
      exec([[cd "%s/git/%s/";git clone https://%s"]], to_dir, to_dir, got)
   end
end
