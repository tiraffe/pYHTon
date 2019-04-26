#!/bin/bash
cd "$(dirname "$0")"

lexer="../bin/lexer"

for filename in lexer/*.py; do
    echo -n "Running test for $filename ..." 
    $lexer < $filename > "$filename.out"
    msg=$(diff "$filename.out" "$filename.ans")
    if [ $? -eq 0 ]
    then
        echo " -- SUCCESS"
        rm "$filename.out"
    else
        echo " -- FAILED"
        echo $"$msg"
    fi
done
