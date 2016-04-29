# Super-LOC-inefficient makefile.

default: page_html_set builds/page_html_set.lua.0.0.tar.bz2

page_html_set: builds/page_html_set.lua/ builds/page_html_set.lua/shatotal files userscripts

builds/page_html_set.lua.0.0.tar.gz:
	cd builds; tar -czf page_html_set.lua.0.0.tar.gz page_html_set.lua/
builds/page_html_set.lua.0.0.tar.bz2:
	cd builds; tar -cjf page_html_set.lua.0.0.tar.bz2 page_html_set.lua/

files: builds/page_html_set.lua/readme.md \
	builds/page_html_set.lua/firejail.sh builds/page_html_set.lua/plain.sh \
  builds/page_html_set.lua/page_html/.init.lua \
	builds/page_html_set.lua/page_html/run.lua \
	license_files

# License stuff.
license_files: builds/page_html_set.lua/licenses/

builds/page_html_set.lua/licenses/:
	cp -ru src/licenses/ builds/page_html_set.lua/

builds/page_html_set.lua/licenses/agpl-3.0.txt: ../agpl-3.0.txt
	cp $< $@

# Userscripts.
userscripts-make:
	cd ../page_html/apps/userscripts; make

userscripts: userscripts-make
	mkdir -p builds/page_html_set.lua/userscripts/; cp -u ../page_html/apps/userscripts/*.user.js  builds/page_html_set.lua/userscripts/

#..
builds/page_html_set.lua/readme.md: src/readme.md
	cp $< $@

builds/page_html_set.lua/shadir.sh: src/shadir.sh
	cp $< $@

builds/page_html_set.lua/firejail.sh: src/firejail.sh
	cp $< $@
builds/page_html_set.lua/plain.sh: src/plain.sh
	cp $< $@

builds/page_html_set.lua/page_html/run.lua: ../page_html/apps/init.lua
	cp $< $@

builds/page_html_set.lua/page_html/.init.lua:  # Sometimes needed?
	touch $@

builds/page_html_set.lua/shasums: builds/page_html_set.lua/shadir.sh
	cd builds/page_html_set.lua/; sh shadir.sh page_html/ > shasums ;

builds/page_html_set.lua/shatotal: builds/page_html_set.lua/shasums
	cd builds/page_html_set.lua/; sha256sum shasums > shatotal

builds/page_html_set.lua/: builds/page_html_set.lua/page_html/

builds/page_html_set.lua/page_html/: build.lua Makefile
	lua build.lua ../page_html/apps/init.lua $@

## Just to show results from that lua file.
say_files:
	lua figure_required.lua ../page_html/apps/init.lua

## Run in firejail
run_firejail:
	cd builds/page_html_set; sh firejail.sh

run_plain:
	cd builds/page_html_set; sh plain.sh

clean:
	rm -r builds/
