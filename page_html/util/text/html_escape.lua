local function html_escape(str)
   return string.gsub(str or "WRONG NIL",
                      "[<>&]", {["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;"})
end

return html_escape
