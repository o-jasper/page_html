-- TODO perhaps nice to make a version integrated with file viewer.

local This = require("page_html.util.Class"):class_derive{__name="page_html.apps.MirrorPage"}

This.name = "history_mirrored"
This.description = "Manages local copies."

function This:init()
   self.mirror_dir = self.mirror_dir or self.data_dir .. "mirror/"
   self.manual_mirror_dir = self.manual_mirror_dir or self.data_dir .. "manual_mirror/"
end

function This:base_uri()
   return string.format("http://localhost:%s/history_mirrored/", self.server.port or 9090)
end

function This:self_uri_pat()
   return string.format("^https?://localhost:%s/history_mirrored/",
                        self.server.port or 9090)
end

local lfs = require "lfs"

local apply_subst = require "page_html.util.apply_subst"

-- TODO this is surely too limited.
This.mirror_msg = {
   base = [[Other than outside assets, this a {%local_mirror}:{%is_top}<br>
<a href="{%uri}"><code>{%uri}</code></a><br>
{%from_time}, size {%gist_size}]],
   pattern = [[{%subfiles}
<hr>{%mirror}]],
   fail_pattern = [[Couldnt read; {%msg} <span style="color:gray">({%code})</span>
<br>{%spell_it}]],
   is_top = [[<span style="color:gray">(top of dir)</span>]],

   image_pattern = [[<br><a href="{%uri}">web</a>,
<a href="{%img_arch}">archive</a>,
<a href="{%img_file}">file</a>
<hr>
<img src="{%img_arch}"></img>]],
}

local function try_file(file)
   local fd, msg, code = io.open(file)
   if fd and fd:read(0) then
      return fd, msg, code
   else
      if fd then fd:close() end
      return nil, msg, code
   end
end
local function save_path(uri)
   print(uri)
   local protocol, rel = string.match(uri, "^([^:]+)://(.*)$")
   return protocol .. "/" .. rel
end

function This:have_mirror_fd(uri)
   local file = self.mirror_dir .. save_path(uri)
   if lfs.attributes(file, "mode") == "directory" then
      return io.open(file .. "/index.html"), "directory", nil, file
   else
      return try_file(file) or try_file(self.manual_mirror_dir .. save_path(uri))
   end
end

function This:have_mirror(uri)
   local fd = self:have_mirror_fd(uri)
   if fd then
      fd:close()
      return true
   end
end

function This:link_part(el)
   local mirror_page = self.server.pages.history_mirrored
   if mirror_page and mirror_page:have_mirror(el.uri) then
      return apply_subst([[<span class="local_version">(<a class="local_version_href"
{%namesys mirror} href="{%local_href}">local</a>)</span>]],
         { local_href = "/history_mirrored/" .. el.uri })
   else
      return " "
   end
end

local gist = require("page_html.util.text.number").gist

This.can_link_direct_file = false

function This:output(args)
   local uri = args.rest_path
   local fd, msg, code, file = self:have_mirror_fd(uri)
   local attrs = lfs.attributes(file) or {}

   if attrs.mode == "file" and fd then
      local str = fd:read("*a")
      fd:close()
      local more = {  -- Make it go inline. (can always manually download.
         ["Content-Disposition"] = string.format("inline; filename=%q", file),
      }
      return str, "application/" .. string.match(file, "[.]([^.]+)$"), more
   end

   local repl = {}
   for k,v in pairs(attrs or {}) do repl[k] = v end

   function repl.spell_it ()
      local ret = {"<table>"}
      for k,v in pairs(attrs or {}) do
         table.insert(ret, string.format("<tr><td>%s</td><td>%s</td></tr>", k,v))
      end
      return table.concat(ret,"\n") .. "</table>"
   end

   repl.from_time = function()
      return attrs.modification and os.date("%c", attrs.modification)  or "N/A"
   end
   repl.gist_size = function() return attrs.size and gist(attrs.size) or "N/A" end

   repl.local_mirror =
      self.can_link_direct_file and [[<a href="{%mirror_href}">local mirror</a>]]
      or "local mirror"
   repl.mirror_href  = "file:/" .. file

   if attrs.mode == "directory" then
      local files = {}
      for f in lfs.dir(file) do
         if not ({["index.html"]=true, ["."]=true, [".."]=true})[f] then
            -- Direct links
            local alt = string.format([[(<a href="%s/html/">html</a>)]], f)
            table.insert(files, string.format([[<a href="%s">%s</a>%s]],
                            f, f, alt))
         end
      end
      repl.subfiles =
         #files > 0 and "<table><tr><td>" ..
         table.concat(files, "<td><tr></tr></td>") .. "</td></tr></table>"
   else
      repl.subfiles = " "
   end

   repl.uri = uri
   repl.is_top = " "
   local mm = self.mirror_msg
   if fd then
      repl.is_top = (code =="directory" and mm.is_top or "")
      repl.mirror = fd:read("*a"),

      fd:close()
      return apply_subst(mm.base .. mm.pattern, repl)
   elseif string.find(file, "/html/$") then
      -- It is html-page-about for files to add stuff about.
      repl.uri = string.match(uri, "^(.+)/[^/]+/html/$")
      repl.img_file = "file://" .. string.match(file, "^(.+)/html/$")
      attrs = lfs.attributes(string.match(file, "^(.+)/html/$")) or {}
      repl.img_arch = self:base_uri() .. string.match(uri, "^(.+)/html/$")
      return apply_subst(mm.base .. mm.image_pattern, repl)
   else  -- Didn't work somehow.
      for k,v in pairs{ msg = msg, code = code or "(nil)" } do repl[k] = v end
      return apply_subst(mm.fail_pattern, repl)
   end
end

This.uri_check = [[^[%a][%w-+.]*://^[^%s#?"';{}()]+[?#]?[^%s"';{}()]$]]
local function check_in_uri(self, uri)
   if string.find(uri, self:self_uri_pat()) then
      print("Already a mirror itself", uri)
   elseif string.find(uri, self.uri_check) then
      print("Is this an okey uri?", uri)
   else
      return save_path(uri)
   end
end

-- local lfs = require "lfs" -- Annoying, where is a `mkdir -p` equivalent..
function This:mirror_uri_html(uri, html, override)
   assert(html)
   local save_path = check_in_uri(self, uri)
   if not save_path then return end

   local dir =  self.mirror_dir .. save_path
   print("history.mirror", dir)
   os.execute("mkdir -p " .. dir)
   local file = dir .. "/index.html"
   local fd = not override and io.open(file)
   if fd then  -- Don't overwrite.(TODO keep versioned?)
      fd:close()
      return nil, true, file
   else
      local fd = io.open(file, "w")
      if fd then
         fd:write(html)
         fd:close()
         return nil, true, file  -- TODO proper location.
      else
         print("history.collect.mirror", "failed to open", dir .. "/index.html")
         return nil, false, file
      end
   end
end

local function exec_format(...)
   print("Exec:", string.format(...))
   return os.execute(string.format(...))
end

This.get_cmd = [[curl "%s" > "%s"]]
function This:mirror_uri(uri, dont_get)
   local save_path = check_in_uri(self, uri)
   if not save_path then return end

   local dir =  self.mirror_dir .. save_path
   exec_format([[mkdir -p "%s"]], dir)
   local append = string.match(uri, "^.+(/[^/]+)$")
   local file = dir .. append
   local no_file_p = (lfs.attributes(file, "size") or 0) == 0
  -- Size equal zero assume something wrong, re-get.
   if no_file_p and not dont_get then
      exec_format(self.get_cmd, uri, file)
      no_file_p = ((lfs.attributes(file, "size") or 0) == 0)
   end
   return self:base_uri() .. uri .. append, not no_file_p, file
end

This.mirror_uri_kr_cmd = [[wget -P "%s" -e robots=off --user-agent=one_page -k -p "%s"]]
function This:mirror_uri_kr(uri)
   local save_path = check_in_uri(self, uri)
   if not save_path then return end

   exec_format(self.get_cmd, self.manual_mirror_dir, uri)

   return self:base_uri() .. uri .. append
end

return This
