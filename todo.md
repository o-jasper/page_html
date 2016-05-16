## TODO

### Note
I have an idea for an overarching approach i am doing.
And some things i might develop, like
a general approach to lists/threads might supersede the current version.

So some of the entries below will be done by tearing apart the code to
and fitting them into concepts.

### Server

* Structure docs, and serve it via the server.

* Some of the assets should do a proper html page with header, etcetera,
  instead of just bits of htm.

* Other programs launched now are just waited out until finishing. I.e. can't do
  things while watching a video.

* Directory browser, modified version for browsing mirrored data.

### Userscripts

* Command-panel `commands.user.js`.
  + Doesn't keep out external CSS
  + Placing not perfect, and not movable or any such.
  + Should be easier to add your own commands, and select which are enabled.

* No private browsing detection.
  [Recently made easy](http://www.greasespot.net/2016/04/greasemonkey-38-release.html),
  hopefully.

* Mirroring just does `document.body.innerHTML`, and is fairly awful.
  + Needs to be possible view the mirrored files without loading assets.

* Quickmarks need to be better. Easy way to delete them and go-and-delete,
  simpler display.

### Mirroring

* More wholesome approach to multiple mirrors.

* Better control of when to mirror, and some good default options.
  (like one copy first, and from the second on one-a-day.)

### Security
* Stronger guards around the SQL table.

* `page_html.util.exec` is a security concern. It does have filters on it.

* Try things that might make abuses via the browser, less effective.

  Like rate-limiting, requiring non-http verification of unlocking features?
 
### Structure of the code/approach

* Stronger principles(see also note)

  + Including the silly distinction between assets and `require`-able code?
    (at least separate into `assets/` though)
  + Probably need way to more succinctly access stuff.

* Use stuff like [alt_require](https://github.com/o-jasper/alt_require.lua) to
  narrow down and describe what lua packages are able to do.

  + And then also be able to review that easily.

* The "upstream" [Searcher](https://github.com/o-jasper/lua_Searcher) is
  outdated, have a much better approach now.(again related to note..)

* Add ability to have multiple good defaults.

* Luajit-sql doesn't work yet. (and other implementations of sql)

### Using programs

* Mpv can be scriptable with lua, including playing http-server. It is an
  alternative to feed videos that way.

  Could try for something like `mpd` using `mpv` and a (lua)script for it.

* `man`, `doc`, `pydoc` could go via server, or figure out why you can
  run userscripts on local files.

  `man` pages could also jut be nicer. And what about `info`?

#### Luakit
* (would-be-nice)Probably eventually try get luakit versions back online?

  It has inbuild sql, which interface can be made to fit the `Sql` used here.

  I'd probably need "my own" way to intergrate the userscript, replacing the
  RPC calls with binds.(alternatively, keep the server aswel)
