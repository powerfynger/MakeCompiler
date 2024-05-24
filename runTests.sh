#!/bin/bash


test_dir="./tests"

GREEN='\033[0;32m'
RED='\033[0;31m'

for file in "$test_dir"/*; do
    output=$(./build/maker "$file" 2>&1)
    total_lines=$(wc -l < "$file")

    if echo "$output" | grep -q "\[+\] Analysis is completed successfully."; then
        echo -e "${GREEN}[✔] $file $total_lines/$total_lines (100%)"
    else
        line_number=$(echo "$output" | grep -oP '(?<=\[Line )\d+(?=\])')
        percentage=$(echo "scale=2; ($line_number / $total_lines) * 100" | bc)
        
        echo -e "${RED}[✖] $file $line_number/$total_lines ($percentage%)"
        # echo "$output" | grep "Line";
    fi
    # echo "-----------------------------"
done