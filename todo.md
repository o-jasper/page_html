## TODO

### Note
I have an idea for an overarching approach i am doing.
And some things i might develop, like
a general approach to lists/threads might supersede the current version.

So some of the entries below will be done by tearing apart the code to
and fitting them into concepts.

### Server

* More docs in server.

* Some of the assets should do a proper html page with header, etcetera,
  instead of just bits of htm.

* Other programs launched now are just waited out until finishing. I.e. can't do
  things while watching a video.
  
* `page_html.util.exec` could have an output log page.
  (conflicts with previous one)

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

### Mirorring

* More wholesome approach to multiple mirrors.

* Better control of when to mirror, and some good default options.
  (like one copy first, and from the second on one-a-day.)

### Structure of the code/approach

* Stronger guards around the SQL table.

* Stronger principles(see also note)

* Use stuff like [alt_require](https://github.com/o-jasper/alt_require.lua) to
  narrow down and describe what lua packages are able to do.

* For at least some functions `page_html.util.exec` has, use another function
  dedicated to, for instance, making a directory instead.

* The "upstream" [Searcher](https://github.com/o-jasper/lua_Searcher) is
  outdated, have a much better approach now.(again related to note..)

### Using programs

* Mpv can be scriptable with lua, including playing http-server. It is an
  alternative to feed videos that way, or add media-center-like stuff
  **later on**.

#### Luakit
* (would-be-nice)Probably eventually try get luakit versions back online?

  It has inbuild sql, which interface can be made to fit the `Sql` used here.

  I'd probably need "my own" way to intergrate the userscript, replacing the
  RPC calls with binds.(alternatively, keep the server aswel)
