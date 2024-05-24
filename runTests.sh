#!/bin/bash


test_dir="./tests"

GREEN='\033[0;32m'
RED='\033[0;31m'

for file in "$test_dir"/*; do
    output=$(./build/maker "$file" 2>&1)

    if echo "$output" | grep -q "\[+\] Analysis is completed successfully."; then
        echo -e "${GREEN}[✔] $file"
    else
        echo -e "${RED}[✖] $file"
        # echo "$output" | grep "Line";
    fi
    # echo "-----------------------------"
done