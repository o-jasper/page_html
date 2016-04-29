#!/bin/bash

# TODO more complete profile.
firejail --private=./page_html/ lua run.lua $@
