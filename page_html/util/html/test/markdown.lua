local md, ops = unpack(require "markdown")
print(md,ops)

print(md([[
----
# testitus
test *1* **2** _3_ ~~4~~ [_**text**_](link)

# test2

    code goes here please [x](y)
    hmm no?


* list 1
* list 2
* list 3

### Headsies
* list 1
* list 2
* list 3
  + sublist A
  + sublist B `**code tag works, _[right](?)_**`
    continued
* sla

<span>
# I `shant` work <quote>or *will* i?</quote>
</span>
# Shall work

<div>in order simpler version, example _of_ breakage, <div>here</div>*indeededly*</div>

----
* noconflict

gotta separate

1. el1
2. el2

]]))

