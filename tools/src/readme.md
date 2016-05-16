---
layout: post
title:  "Finally put together page_html"
date:   2016-05-16 2:16
categories: Programs
---

**Finally** put together
[page_html](https://github.com/o-jasper/page_html/#html-page-and-asset-system),
so that linux/unix users don't have to gather the whole bunch git repos of and
configure lua to load it properly. I also fixed some annoyances.

It has userscripts talking to the server. One main one is
`commands.user.js`, which is a commands panel that can be brought up with
Control-";". The below also represents the features it brings:

* Bookmarks, using `bm` in the command interface userscript. Has a searchable
  listing in:
  [`http://localhost:9090/bookmarks`](http://localhost:9090/bookmarks)
  <p>Entries can be deleted/altered there aswel. No entering new ones there yet.</p>

* Browsing history. Has a searching history:
  [`http://localhost:9090/history`](http://localhost:9090/history).

* The userscripts that implement the history/commands can be obtained in
  [`http://localhost:9090/userscripts`](http://localhost:9090/userscripts).
  <p>They've been tested with firefox on [Greasemonkey](http://greasespot.net/).</p>

* Mirroring using `document.innerHTML`, crude, but then javascript doesn't seem
  to have good options here. Runs all the time the corresponding userscript is
  enabled.

* `mirror` mirrors manually in another way;
  <p>
  `wget --convert-links -P "%s" -e robots=off --user-agent=one_page_plz -p "%s"`</p>

* `vid` command runs [`mpv`](http://mpv.io)(if that exists) on the hovered/current
  uri.
  <p>It doubles as command to mirror images and pdfs. Saves having to organize
  those files when you download them. Viewing them with pdf.js, you can also
  bookmark them.</p>

* `syms` allows for easily getting a html symbol in your clipboard.

* `qm` and `gqm` do quickmarks, but it isn't what i want, the list doesn't
  traverse easily enough, and needs to be easy way to "delete-and-go" for
  quickmark functionality.

It has keyboard(arrow) navigation everywhere. Control-arrows moves around.

### Some screenshots
Note that is shows SQL, it can also run it.
(Note: that may be a security concern, defaultly turned it off in lua)
But you can just throw in search terms in the input
above. Something like `tags:something` should also work.

<img src="/blog/parts/page_html_screens/2016-04-29:22:01:35.png"
title="Screenshot of bookmarks with symbol-getter">
<img src="/blog/parts/page_html_screens/2016-04-29:22:03:16.png"
title="Screenshot of bookmark command.">
<img src="/blog/parts/page_html_screens/2016-04-29:22:00:54.png"
title="Screenshot of browser history.">

#### Getting it
The file is at
[ojasper.nl/data/data/page\_html\_set.lua.0.0.1.tar.gz](http://ojasper.nl/data/page_html_set.lua.0.0.1.tar.gz),
contains instructions. Basically run one of the shellscripts from its own directory.

Windows isn't particularly supported suspect it is a matter of the correct
lua-socket `.DLL` being loadable, and then running lua with packages available, but i
am not sure.(careful with `.DLL`s you trust)

for those with Arch Linux, there is an
[PKGBUILD](https://github.com/o-jasper/page_html/tree/master/tools/pkg/PKGBUILD).
With that, running `page_html.lua` defaultly it runs on port `9090` that can be
specified, but then you have to update the userscripts to read the right port aswel.

Once running, [`http://localhost:9090/userscripts`](http://localhost:9090/userscripts)
contains the userscripts, [Greasemonkey](http://www.greasespot.net/) can load them by
just visiting the files. Haven't tested other userscript implementations.

The `PKGBUILD` does not follow etiquette properly. It just writes down
`/usr/bin/page_html.lua` with a `package.path` loading the lua from
`/usr/local/share/page_html.lua/` which just contains the same as the `tar.gz`.
In the future `PKGBUILD`s should be done better.
(afaics, its not particularly bothersome to anyone?)

#### Customizing
There is some room for it;

* `~/.page_html/assets/$PAGE_NAME/assets/` can contain extra assets for said
  page.

* `~/.page_html/lua/` is looked in first; you can replace lua files, particularly:

  + `page_html.util.exec_allowed` patterns controlling limitations on `os.execute`.
  + `page_html.apps.util.cmds` contains the commands avaiable from util.
    <p>However, no way to readily add any to the command-interface yet
        (though you could modify)</p>
  + `page_html.apps.util.mirror_image_detect` recognizes files for
    downloading-as-local mirror.
  + `page_html.run` where lua enters.

Nice modifications can be sent as pull-requests.

### Not quite there yet
There are many things that should be improved.. Like:

* No private browsing detection.
  [Recently made easy](http://www.greasespot.net/2016/04/greasemonkey-38-release.html),
  hopefully.

* Command-panel:
  + Doesn't keep out external CSS
  + Placing not perfect, and not movable or any such.
  + Should be easier to add your own commands.
  
* Mirrorer only keeps automatic/manual mirroring separate. A more wholesome
  approach would be better. Also viewing it, would be nice to just essentially
  browse the directories.

* Server itself should provide more docs.

Those things probably most directly affect experience but then the below are
important too.

* Use stuff like [alt_require](https://github.com/o-jasper/alt_require.lua) to
  narrow down what lua packages are able to do.

* Use `page_html.util.exec` less.(at least it all goes through there now)

* The `Formulator` thing generating lua seems to work fine, I have a much better
  way to do all the database stuff.

[Hardly exhaustive](https://github.com/o-jasper/page_html/blob/develop/todo.md),
of course!

### Scratching the surface
Finally, there are more tools a browser can have, and these could clearly be far
more customizable. It is a ghost of the functionality i want to have.
I want the bookmarks to be sharable to different levels from between-friends to
completely public. And preferably not with a single way of transferring the data.

I have been thinking about a overarching approach to fit that into. Applying it
seemed like waiting too long to release it, but fixing the things ignores the
new approach, so just got rid of annoyances and did the low-hanging fruits.

The new approach is
[like this post](http://ojasper.nl/blog/software/2015/11/12/libre_bus.html)
changed and worked out further. Later i'll post about the approach.
