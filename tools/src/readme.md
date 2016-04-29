# This is page_html things packaged together
Userscripts talk to lua server, implementing via that:(using sqlite)

* History.
* Mirroring `document.InnerHTML` (written in files)
* Bookmarks.(There is a half-finished "comments" thing in there too)

This is currently developed at
[github.com/o-jasper/page_html](https://github.com/o-jasper/page_html).
**I would not rate it ready for general consumption**, at least, by people
who mind the instructions, or maybe even just windows users. It is not tested
on windows, but the linux/unix commands probably won't work there.

There are some annoyances, listed below. Still also some things i feel are
better, like bookmarking feels smoother to me. And it makes use of the
selection to defaultly fill a "quote" field. As does searching
history/bookmarks. Don't know why firefox doesn't do these things similar as
this.

There are some other things:

* Running `mpv` on files, done by the `vid` command.

  Later on i *mis*appropriated for selecting (non-video)images, and pdfs to
  mirror aswel. Saves organizing your files; they're at places analogous to
  the web. And you can bookmark them aswel.

  Unfortunately, it isn't entirely effective. Currently arxiv says it is
  "forbidden". Perhaps curl or something needs to be used itself.

* `man` commands gets man pages. `doc` command searches for other document
  files.

* `syms` allows you to write HTML symbols, they'll be pastable.

### Requirements.

Requires [lua](http://www.lua.org/) itself,
[lua-sqlite-bindings](http://www.keplerproject.org/luasql/),
[lua-socket](https://github.com/diegonehab/luasocket). Linux distros will
usually have them in their repositories, expect that it just works if you
install the appropriate packages. Perhaps in the future `.so` and
`.DLL`s will accompany this. I may not, or i might use the code in another
way, have my own bookmarks to put in that case, so that should be there then.

Afaics, the rest is packaged-in.
"The rest" includes [Pegasus](https://github.com/EvandroLG/pegasus.lua/),
and projects of mine like [PegasusJs](https://github.com/o-jasper/PegasusJs),
[storebin](https://github.com/o-jasper/storebin).

### To run:

    cd $DIRECTORY_OF_THIS_FILE
    sh plain.sh
    # sh firejail.sh  # if you have that.

Commented out currently uses firejail in a very basic manner. Defaultly it
runs on `9090`, first argument of the shellscripts can set that.


If the port is `9090`, `http://localhost:9090/history` is the history and
`http://localhost:9090/bookmarks` the bookmarks.

### To use
Your browser needs the `userscripts/`. Particularly `althist.user.js` and
`commands.user.js`.

For firefox [Greasemonkey](http://www.greasespot.net/) is an addon for
userscripts.

`althist.user.js` just records the history. Disable the userscript to
disable it.

With `commands.user.js` userscript loaded and enabled, Control-";" should
bring it up. Note that

**Note: currently does not keep track of private mode.** Userscripts cannot
readily detect it. Sorry, this is pretty annoying.

### Notes:
`shasums` and `shatotal` serve little purpose, can be used to check if things
are as-distributed.

It creates a `~/.page_html/`; `~/.page_html/data/main.db` is a sqlite database
with bookmarks and hitstory and `~/.page_html/data/mirror/` contains mirrored
`.innerHTML` and mirrored pdfs/images.
(if using it with firejail, these files are in that sandbox, of course!)

### TODO/Known annoyances (may still put them in issues)

* I try to make things keyboard-navigable. But it isn't perfect, because of
  overlap with what the widgets need in keyboard events and what i want.

  TODO try just control-arrow equates keyboard-navigable.

#### Commands panel

* ... placing can be annoying if you're still reading while trying
  to figure what to put in bookmark-description, for instance.

* ... takes CSS of page.

* ... element ids could overlap with those in the page. This affects
  the history and bookmarks page currently! (downright bug)
  
* ... doesn't give focus back after you're done with it.

* ... should be easier to extend with your own commands, and 

#### Other

* Mirrorer always overwrites. Terrible if a page disappears, and the discovery
  also deletes your record >< How to solve it efficiently, though..
  (do it inefficient?)

* No private-browsing detection. See it can do it, in 3.8.

* Poor hovered-detection.

* Userscripts, man-pages etcetera could be served up by server. Or have both
  options. Userscripts seem to have limitations in that they cannot operate on
  files.

* It doesn't hold back, it'd be better if stuff like `os.execute` was used less
  in the code.

* Really not sure how much sense this makes, might be better to make packages for
  package managers. Related to below though, just don't quite think it ready.

* The database and searching in it is essentially obsolete, i can do better now.
  (related to below)

Finally, there are more tools a browser can have. Scratching the surface, even of just
what i can imagine. However, i have been thinking about a overarching approach,
to which this would be fit into.
