#!/bin/bash

echo "// In current case not preferred form of editing!"
echo "// As of 2-2016 see github.com/o-jasper/page_html"
echo

cat $1 | while IFS='' read -r line; do  # Shell sucks.
    INSERT=$(echo $line | tail -c+4)
    case "$line" in
        =a=*.htm)
            echo // -insert-asset-htm  $INSERT
            cat ../../assets/$INSERT | while IFS='' read -r ln; do
                echo "h += \"$ln\";"
            done
            echo // -end ;;
        =a=*)
            echo // -insert-asset  $INSERT
            sh compose.sh ../../assets/$INSERT
            echo // -end ;;
        =s=*)
            echo // -insert-source $INSERT
            sh compose.sh src/$INSERT
            echo // -end ;;
        *)
            echo "$line" ;;
    esac
done
