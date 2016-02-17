#!/bin/bash

echo "// In current case not preferred form of editing!"
echo "// As of 2-2016 see github.com/o-jasper/page_html"
echo

cat $1 | while read line; do
    INSERT=$(echo $line | tail -c+4)
    case "$line" in
        =a=*)
            echo // -insert-asset  $INSERT
            cat ../../assets/$INSERT
            echo ;;
        =s=*)
            echo // -insert-source $INSERT
            cat src/$INSERT
            echo ;;
        *)
            echo "$line" ;;
    esac
done
