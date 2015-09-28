local split = require "page_html.util.split"

print("---split---")
for k,v in split("a 1 4bfs 46 a fsa h hehr") do
   print(k,v)
end

print("---pkgs---")
local pkgs = require "page_html.util.pkgs"
for k,v in pkgs("124;33463;43643/?.lua;2352") do print(k,v) end

print("--tabu--")
local tab = require "page_html.util.list"
for k,v in pairs(tab(split("a 1 4bfs 46 a fsa h hehr"))) do print(k,v) end
