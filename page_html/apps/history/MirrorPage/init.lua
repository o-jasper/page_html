-- TODO perhaps nice to make a version integrated with file viewer.

local GotAssets = require "page_html.GotAssets"
local This = GotAssets:class_derive{__name="page_html.apps.MirrorPage"}

This.name = "history_mirrored"
This.description = "Manages local copies."

This.where = {"page_html/apps/history/MirrorPage/"}

function This:init()
   GotAssets.init(self)

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
local exec = require "page_html.util.exec"

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
   local protocol, rel = string.match(uri, "^([^:]+)://(.*)$")
   return protocol .. "/" .. rel
end

function This:have_mirror_fd(uri)
   local file = self.mirror_dir .. save_path(uri)
   if lfs.attributes(file, "mode") == "directory" then
      return io.open(file .. "/index.html"), "directory", nil, file
   else
      local fd, msg, code = try_file(file)
         or try_file(self.manual_mirror_dir .. save_path(uri))
      return fd, msg or "(no msg)", code, file
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

function This:repl(file)
   local attrs = lfs.attributes(file) or {}

   -- Some kind of page, make repl.
   local repl = {}
   for k,v in pairs(attrs or {}) do repl[k] = v end

   repl.list_attrs = function ()
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
   return repl
end

This.direct_file_types = { png=true, jpg=true, jpeg=true, svg=true, pdf=true, ps=true }

function This:fail_output(file, msg, code, repl)
   repl = repl or {}
   for k,v in pairs{ msg = msg, code = code or "(nil)" } do repl[k] = v end
   return apply_subst(self.assets:load("failed.htm"), repl)
end

local function finally_output(self, file, ret)
   local tp = string.lower(string.match(file, "[.]([^.]+)$") or "")
   local tp = self.direct_file_types[tp] and "application/" .. tp or nil
   if tp then
      local more = {  -- Make it go inline. (can always manually download.)
         ["Content-Disposition"] = string.format("inline; filename=%q", file),
      }
      return ret, tp, more
   else
      local ret = apply_subst(self.assets:load("base.htm"), self:repl(file)) .. ret
      return ret  -- TODO extract external referencing.
   end
end

local function readall(fd)
   if fd then
      local ret = fd:read("*a")
      fd:close()
      return ret
   end
end

function This:output(args)
   local manual_uri = string.match(args.rest_path, "^/?manual/[%w+-]+://?(.+)$")
   if manual_uri then -- Manual one.
      local data = readall(io.open(self.manual_mirror_dir .. manual_uri))
         or readall(io.open(self.manual_mirror_dir .. manual_uri .. "/index.html"))
      if data then
         return finally_output(self, string.match(manual_uri, "[^/]*$"), data)
      end
   end

   local uri = string.match(args.rest_path, "^(.+)/html/$")
   if uri then  -- It is a page with the thing in it.
      local fd, msg, code, file = self:have_mirror_fd(uri)
      local repl = self:repl(file)
      if fd then  -- And can actually find the file.
         fd:close()
         repl.uri = string.match(uri, "^(.+)/[^/]*$")
         repl.img_file = "file://" .. file
         repl.img_arch = self:base_uri() .. uri
         return apply_subst(self.assets:load("base.htm") ..
                               self.assets:load("image.htm"), repl)
      end
   end
   local fd, msg, code, file = self:have_mirror_fd(args.rest_path)
   if not fd then return self:fail_output(file, msg, code) end

   return finally_output(self, file, readall(fd))
end

This.uri_check = [[^[%a][%w-+.]*://[^%s#?"';{}()]+[?#]?[^%s"';{}()]*$]]
local function check_in_uri(self, uri)
   if string.find(uri, self:self_uri_pat()) then
      print("Already a mirror itself", uri)
   elseif not string.find(uri, self.uri_check) then
      print("Failed: uri didn't check out?", ":" .. uri ..":")
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
   exec([[mkdir -p "%s"]], dir)
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

This.call_progs = { -- TODO make them patters instead of %s}
   curl = [[curl "%s" > "%s"]],
   wget_kr = [[wget --convert-links -P "%s" -e robots=off --user-agent=one_page_plz -p "%s"]],

-- Note: has somewhat of a signature. Perhaps better to put on separate Tor instance.
   tor_curl = [[torify curl "%s" > "%s"]],
   tor_wget_kr = [[torify wget --convert-links -P "%s" -e robots=off --user-agent=one_page_plz -p "%s"]],
}

This.mirror_cmd_name = "curl"

function This:mirror_uri(uri, dont_get, cmd_name)
   local save_path = check_in_uri(self, uri)
   if not save_path then return end

   local dir =  self.mirror_dir .. save_path
   exec([[mkdir -p "%s"]], dir)
   local append = string.match(uri, "^.+(/[^/]+)$")
   local file = dir .. append
   local no_file_p = (lfs.attributes(file, "size") or 0) == 0
  -- Size equal zero assume something wrong, re-get.
   if no_file_p and not dont_get then
      exec(self.call_progs[cmd_name or self.mirror_cmd_name], uri, file)
      no_file_p = ((lfs.attributes(file, "size") or 0) == 0)
   end
   return self:base_uri() .. uri .. append, not no_file_p, file
end

This.mirror_kr_cmd_name = "wget_kr"

function This:mirror_uri_kr(uri, cmd_name)
   local save_path = check_in_uri(self, uri)
   if not save_path then return end

   exec(self.call_progs[cmd_name or self.mirror_kr_cmd_name], self.manual_mirror_dir, uri)

   return self:base_uri() .. "/manual/" .. uri
end

return This
