# Html page and asset system

### Assets lib
The asset package allows you to specify a cascading set of directories
where assets will be searched for.

* `Assets:new{...}`
  + `where`: where to search for assets. Defaultly `{"assets/"}`

    If you want all parent paths to be considered good, preceed with entries with
    `*`.
  + `memorize`: disable memoizeing with `false`, defaultly
    enabled.

    Defaultly all memoizing shared among all instances! `memoize={}` to
    stop that.
* `:load(path)` loads a particular path.

Rest is less important.

* `:path(path)` produces an exact path to the file.
* `:open(path)` opens a file descriptor. Does not use memoizing currently!
* `:load_direct(path)`

The directories are relative to directories inferred from `package.path`.

## Page lib
The page package allows you to provide objects with appropriately defined
methods, and then create a page as you go. Some defaults are filled
using assets.

Pages have different implementations, currently just;

1. `pegasus` with RPC-javascript via PegasusJs.
2. `luakit_chrome`. 

The implentations can be obtained with `require "omniPub_html.html.<implementation>"`
They have:

* `Implementation:new{}` creates the object.(NOTE: i.e. luakit only one is possible)
* `:start()` starts the server.

  If no server, in order to keep things the same, pages are disabled until this is called.
  Note that it is an "endless loop" function. I.e. for pegasus it stops when the
  server stops.
* `:add(pages...)` add pages defined by the below.

### defining a bare page
A page that is to be imbedded in another page.

* `.name` name of the thing.
* `:repl(state, ...)`, a key-value store of replacements in the text.

  If not found in `:repl` or `:repl` not provided, 

The latter is optional; alternatively, can directly define.

* `:output(state, ...)` outputs code based on a state. Html code in some cases.
  `state` is the condition it is in. You can change the `state` as you go.
   Rest of the arguments are simply passed on.

Also it will will defaultly search for the data to replace in the path
`:name() .. ".html"`  via assets, but alternatively this can be defined;

* `:repl_pattern()`, 

In the replaced-texts  `{%...}` in there are replaced from values
in `:repl` or   assets. For  `{%inject_js}` is needed in the header
to do the client-side javascript.

### defining a full page
Not really to be used as mere part of something.
It additionally defines:

* `.where` a list of places to look for assets.(just comes from the above.)
* `:rpc_js()` a key-value store of javascript functions to RPC.

### Installing(linux)
In `~/.init.lua`(other whatever initiates lua, add.

    package.path = "$THIS_PROJECT/?.lua;$THIS_PROJECT/?/init.lua;" .. package.path

#### Alternatively:

* Add a `~/.lualibs/`
* Add/edit the `~/.init.lua` adding.

    package.path = "/home/$USER/.lualibs/?.lua;/home/$USER/.lualibs/?/init.lua;"
        .. package.path

Then, symmlink this thing to there.

* `cd ~/.lualibs/ ; ln -s path-to-project/html_page/``

#### Dependencies
The different implementations depend on their respective thing.

* Luakit for `luakit_chrome`

* Pegagus and [PegasusJs](https://github.com/o-jasper/PegasusJs)
  for the [pegasus](http://evandrolg.github.io/pegasus.lua/) variant.

## Lua Ring

* [lua_Searcher](https://github.com/o-jasper/lua_Searcher) sql formulator including
  search term, and Sqlite bindings.

* [page_html](https://github.com/o-jasper/page_html) provide some methods on an object,
  get a html page.(with js)

* [storebin](https://github.com/o-jasper/storebin) converts trees to binary, same
  interfaces as json package.(plus `file_encode`, `file_decode`)
  
* [PegasusJs](https://github.com/o-jasper/PegasusJs), easily RPCs javascript to
  lua. In pegasus.

* [tox_comms](https://github.com/o-jasper/tox_comms/), lua bindings to Tox and
  bare bot.
