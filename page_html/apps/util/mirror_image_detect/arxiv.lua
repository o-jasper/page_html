return function(uri)
   -- Detects arxiv.
   local arxiv = string.match(uri, "^https?://arxiv[.]org/pdf/([%w.]+)") or
      string.match(uri, "^https?://arxiv[.]org/abs/([%w.]+)")
   return arxiv and "https://arxiv.org/pdf/" .. arxiv .. ".pdf"
end
