
default: userscripts

userscripts: althist.user.js althist.mirror.user.js commands.user.js 

usual: assets/figure_server.js gen.lua Makefile

%.user.js:
	lua gen.lua $@ > $@

althist.user.js: assets/userscripts/althist.user.js usual

althist.mirror.user.js: assets/userscripts/althist.mirror.user.js usual

command_parts: \
	assets/make_bookmark.js assets/cmd_on_string.js  assets/cmd_vid.js

commands.user.js: assets/userscripts/commands.user.js command_parts usual
