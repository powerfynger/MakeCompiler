#!/bin/bash

test_dir="./tests"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'

total_errors=0

if [[ "$1" == "-d" ]]; then
    debug_mode=true
else
    debug_mode=false
fi

for file in "$test_dir"/*; do
    output=$(./build/maker "$file" 2>&1)
    total_lines=$(wc -l < "$file")

    error_count=$(echo "$output" | grep -c "Error")
    total_errors=$((total_errors + error_count))

    if echo "$output" | grep -q "\[+\] Analysis is completed successfully."  && [ "$error_count" -eq 0 ]; then
        echo -e "${GREEN}[✔] $file $total_lines/$total_lines (100.00%). Number of errors $error_count"
        # echo ""
    else
        line_number=$(echo "$output" | grep -oP '(?<=\[Line )\d+(?=\])' | tail -1)
        if [ -z "$line_number" ]; then
            line_number=0
        fi
        passed_lines=$(($total_lines - error_count))
        if [ "$passed_lines" -lt 0 ]; then
            passed_lines=0
        fi
        percentage=$(echo "scale=2; ($passed_lines / $total_lines) * 100" | bc)
        if (( $(echo "$percentage > 50" | bc -l) )); then
            echo -e "${YELLOW}[⚠] $file $passed_lines/$total_lines ($percentage%). Number of errors $error_count "
        else 
            echo -e "${RED}[✖] $file $passed_lines/$total_lines ($percentage%). Number of errors $error_count "
        fi
    fi
    if [[ $debug_mode == true ]]; then
        echo -e "------------------------------------\n"
        echo "$output"
        echo -e "------------------------------------\n"
    fi
done

echo -e "${RED}Total Errors: $total_errors"
