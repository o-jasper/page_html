local function html_escape(str)
   return string.gsub(str, "[<>&]", {["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;"})
end

return html_escape
