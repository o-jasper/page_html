local base64 = require "page_html.util.fmt.base64"

print(base64.enc_file("/dev/stdin"))
