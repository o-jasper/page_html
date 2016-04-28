#!/bin/bash

#  Used to create a file for monitorring when it changes.
# Note: if you have no copy, you have no recourse.

find $1 -type f | while read line; do sha256sum $line; done
