#!/bin/bash


test_dir="./tests"


for file in "$test_dir"/*; do
    output=$(./build/maker "$file" 2>&1)

    if echo "$output" | grep -q "\[+\] Analysis is completed successfully."; then
        echo "[✔] $file"
    else
        echo "[✖] $file"
        # echo "$output" | grep "Line";
    fi
    # echo "-----------------------------"
done