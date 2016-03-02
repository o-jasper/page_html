# Collects all the lua code together

It statically finds all the files `require` that uses a plain string.
(i have a "nothing fancy" rule for this project)

Then puts all those files into a single directory.

The output is not yet tested, and it would not work because the asset files
are not yet transferred.

Currently the lua files output, add up to mere 5.4kLOC, that includes
all upstream lua code. (currently only `json.lua` and `socket.lua` not
altered/made by myself)
