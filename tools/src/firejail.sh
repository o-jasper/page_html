#!/bin/bash

# TODO more complete profile. Preferably including opening up the one particular
# port and stuff..

firejail --private=./page_html/ lua run.lua $@
