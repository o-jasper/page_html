-- Note just written out so easy text-based static detection of dependencies.
return {
   pydoc = require "page_html.apps.util.cmds.pydoc",   doc   = require "page_html.apps.util.cmds.doc",
   man   = require "page_html.apps.util.cmds.man",
   vid   = require "page_html.apps.util.cmds.localize_or_mpv",
   mirror = require "page_html.apps.util.cmds.mirror",
}
