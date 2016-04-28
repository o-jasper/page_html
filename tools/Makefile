page_html_set: builds/page_html_set/ builds/page_html_set/shatotal files

files: builds/page_html_set/readme.md builds/page_html_set/agpl-3.0.txt \
	builds/page_html_set/firejail.sh builds/page_html_set/plain.sh \
  builds/page_html_set/page_html/.init.lua \
	builds/page_html_set/page_html/run.lua

builds/page_html_set/agpl-3.0.txt: ../agpl-3.0.txt
	cp $< $@

builds/page_html_set/readme.md: src/readme.md
	cp $< $@

builds/page_html_set/shadir.sh: src/shadir.sh
	cp $< $@

builds/page_html_set/firejail.sh: src/firejail.sh
	cp $< $@
builds/page_html_set/plain.sh: src/plain.sh
	cp $< $@

builds/page_html_set/page_html/run.lua: ../page_html/apps/init.lua
	cp $< $@

builds/page_html_set/page_html/.init.lua:  # Just make it.
	touch $@

builds/page_html_set/shasums: builds/page_html_set/shadir.sh
	cd builds/page_html_set/; sh shadir.sh page_html/ > shasums ;

builds/page_html_set/shatotal: builds/page_html_set/shasums
	cd builds/page_html_set/; sha256sum shasums > shatotal

builds/page_html_set/: builds/page_html_set/page_html/

builds/page_html_set/page_html/: build.lua Makefile
	lua build.lua ../page_html/apps/init.lua $@

## Just to show results from that lua file.
say_files:
	lua figure_required.lua ../page_html/apps/init.lua

## Run in firejail
run_firejail:
	cd builds/page_html_set; sh firejail.sh

run_plain:
	cd builds/page_html_set; sh plain.sh
