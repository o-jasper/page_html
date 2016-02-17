
default: userscripts

userscripts: althist.user.js althist.mirror.user.js commands.user.js 

althist.user.js: src/althist.user.js compose.sh
	sh compose.sh $< > $@

althist.mirror.user.js: src/althist.mirror.user.js compose.sh
	sh compose.sh $< > $@

commands.user.js: src/commands.user.js compose.sh
	sh compose.sh $< > $@
