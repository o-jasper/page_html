return function(uri)
   -- Detects arxiv.
   local arxiv = string.match(uri, "^https?://arxiv[.]org/pdf/(.+)") or
      string.match(uri, "^https?://arxiv[.]org/abs/(.+)")
   return arxiv and "https://arxiv.org/pdf/" .. arxiv .. ".pdf"
end
