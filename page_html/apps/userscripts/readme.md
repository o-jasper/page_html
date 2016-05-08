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

* Command-panel
  + Doesn't keep out external CSS
  + Placing not perfect, and not movable or any such.
  + Doesn't place focus back where it was when done with command.

* More modularity in the construction of `commands.user.js`.

  Allow selecting what features are desired.

* No private browsing detection.
  [Recently made easy](http://www.greasespot.net/2016/04/greasemonkey-38-release.html),
  hopefully.
