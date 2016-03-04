
default: userscripts pass

userscripts: althist.user.js althist.mirror.user.js commands.user.js 

usual: src/figure_server.js compose.sh Makefile

althist.user.js: src/althist.user.js usual
	sh compose.sh $< > $@

althist.mirror.user.js: src/althist.mirror.user.js usual
	sh compose.sh $< > $@

command_parts: \
	src/make_bookmark.js src/cmd_on_string.js  src/cmd_vid.js

commands.user.js: src/commands.user.js command_parts usual
	sh compose.sh $< > $@

pass:
	sh pass.sh
