# Collects all the lua code together

It statically finds all the files `require` that uses a plain string.
(i have a "nothing fancy" rule for this project)

Then puts all those files into a single directory.

The output is not yet tested, and it would not work because the asset files
are not yet transferred.

Currently the lua files output, add up to mere 6.7kLOC, with upstream and
5.8kLOC "everything i wrote". Think i can do better.(lower)

### Commands
`make` defaultly does `make page_html_set` which constructs the set.

After that `make run_firejail` runs it in firejail. If you have, and used
firejail, you might aswel use it now aswel. `make run_plain` runs it
plainly.

Note that there is `readme.md` in the output.
