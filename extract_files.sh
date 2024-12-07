#!/bin/bash

# Output file
OUTPUT_FILE="output.txt"

# Clear or create the output file
> "$OUTPUT_FILE"

# Find all files recursively, excluding unwanted files
find ./dotDNS -type f \
    ! -path "*.xcodeproj/*" \
    ! -name ".DS_Store" \
    ! -path "*.xcassets/*" \
    ! -path "*/xcuserdata/*" \
    ! -path "*/xcshareddata/*" \
    ! -name "*.plist" \
    ! -name "*.pbxproj" \
    | while read -r file; do
        # Write file path marker
        echo "=== File: $file ===" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Write file content
        cat "$file" >> "$OUTPUT_FILE"
        
        # Add separators for readability
        echo "" >> "$OUTPUT_FILE"
        echo "=== End of $file ===" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "----------------------------------------------------------------" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    done