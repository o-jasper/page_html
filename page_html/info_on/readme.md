# Adding info to things
For going through items, and then finding other information on them.

A list of info-getters must be provided, these can either:

* `:newlist(context, entry)`: (potentially empty) list of other informations
  found.
* `:new{context=context, e=entry}` single item.

The information gets priorities, objects that provide information must have
`:priority()` (this can be context dependent using above)

# Info-function sorting by importance.

`Class:newlist(args)`, if exists, can return a list of new infofun objects.
`nil` is interpreted as `{}`. `args.creator` contains the creator, and
`args.e` contains the entry as provided.

`Class:newlist` does not exist, `{Class:new({ creator = creator, e=entry })}`
is used.

Otherwise `:priority()` indicating a priority. Want to have
importance-based-on-context. I.e. image-viewing, the image has high importance,
file-viewing, it just shows as filename.(maybe tiny-fied version)

## Uses
Intention is use in user interfaces/suggested actions/things to view.
