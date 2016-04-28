# This is page_html things packaged together
Userscripts talk to lua server, implementing via that:(using sqlite)

* History.
* Bookmarks.(There is a half-finished "comments" thing in there too)

This is currently developed at
[github.com/o-jasper/page_html](https://github.com/o-jasper/page_html).

Requires [lua](http://www.lua.org/) itself,
[lua-sqlite-bindings](http://www.keplerproject.org/luasql/),
[lua-socket](https://github.com/diegonehab/luasocket). Linux distros will
usually have them in their repositories. Perhaps in the future `.so` and
`.DLL`s will accompany this. On the other hand, i am taking another
direction, so they may not.

Afaics, the rest is packaged-in.
"The rest" includes [Pegasus](https://github.com/EvandroLG/pegasus.lua/),
and projects of mine like [PegasusJs](https://github.com/o-jasper/PegasusJs),
[storebin](https://github.com/o-jasper/storebin).

To run:

    cd $DIRECTORY_OF_THIS_FILE
    sh plain.sh
    # sh firejail.sh  #if you have that.

uses firejail in a very basic manner. (keeping the configuration in this directory.)

### Notes:
Some readmes etcetera are copied along.
`shasums` and `shatotal` can be used to check if things were at all
changed.

