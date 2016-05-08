--  Copyright (C) 15-02-2016 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the Afrero GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ThreadView = require "page_html.ThreadView"
local Bookmarks = require "page_html.apps.bookmarks"
local This = ThreadView:class_derive{ name="comments", __name="page_html.apps.comments" }

This.Formulator = require "page_html.apps.bookmarks.Formulator"
This.Db         = require "page_html.apps.bookmarks.Bookmarks"

This.where      = {"page_html/apps/comments/",
                   "page_html/apps/bookmarks/", "page_html/ThreadView/",
                   "page_html/ListView/", "page_html/"}
This.assets_arg = {where = This.where}

This.table_wid = 4

This.pats = {}
for k,v in pairs(Bookmarks.pats)  do This.pats[k] = v end
for k,v in pairs(ThreadView.pats) do This.pats[k] = v end

This.Statementizer_list = require "merkle.statement.all"
This.default_statement_type = "Sha256"

-- Figures out the hash.
function This:el_update_hash(el, assert_it, coerce_type)
   local tp =  -- Figure the hash type, or use the default.
      coerce_type or
      el.root_hash and string.match(el.root_hash, "^[^:]+") or self.default_statement_type
   local stmt = self.Statementizer_list[tp]:new()
   local root_hash = self.root_hash
   el.root_hash = nil  -- Set to nil.
   local id = el.id
   el.id = nil

   el.root_hash = stmt:make_text(el)  -- Set hash.
   el.id = id

   if not root_hash or root_hash ~= "" or el.root_hash ~= root_hash then
      assert(not assert_it)
      self.lister.db:set_root_hash(el.id, el.root_hash)  -- Update in db.
      return false
   end
   return true
end

function This:el_uri(el)
   if (not el.root_hash) or el.root_hash == "" then  -- Create hash if doesn't exist.
      self:el_update_hash(el)
   end
   return "comment:" .. el.root_hash
end

function This:select_thread(form, el)
   -- Uris are where the comments are from, this finds comments on this comment.
   form:like("uri", self:el_uri(el) .. "/%")
end

function This:el_repl(el, state)
   return Bookmarks._el_repl(self, el, state, ThreadView.el_repl(self, el, state))
end

function This:form(st, args)
   local form = self.lister:form(st, args)

   local to_root_hash = string.match(args.rest_path or "", "^/?rh/([^/]+)/?")
   if to_root_hash then form:equal("root_hash", to_root_hash) end

   local to_uri       = string.match(args.rest_path or "", "^/?uri/([^/]+)/?")
   if to_uri then form:equal("uri", to_uri) end   

   return form
end

function This:repl(args)
   local ret = ThreadView.repl(self, args)
   -- That part of the path we care to share.
   for _, el in ipairs({"uri", "rh"}) do
      ret.rest_path = string.match(args.rest_path or "", "^/?" .. el .. "/[^/]+/?")
      if ret.rest_path then break end
   end
   return ret
end

return This
