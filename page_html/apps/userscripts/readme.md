## Userscripts
They're written in parts and put together, because i dont like how userscript'
libraries work.

Currently all these work with the lua server stuff.

* `althist.user.js` keeps history.
* `commands.user.js` does commands, including making bookmarks and using `mpv`
  to view videos.
* `althist.mirror.user.js` Part of the history-saver that *just* does.
  (defaultly the other one already does this)

## TODO

* Detecting hovered links is iffy, works annoyingly badly.

* Commands panel takes over CSS from the page too much.

* element `id`s can overlap with stuff on the page.

* Quite annoying how gui js code has to be embedded into `commands.user.js`,
  even though the "building system" already makes this less..

  Perhaps could have a list of (sha256) checksums of *allowed* code, and just
  have the server check those, so the server can send along unavailable code.


