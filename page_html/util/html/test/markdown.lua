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
  + sublist B
    continued
* sla

----
* noconflict

]]))
