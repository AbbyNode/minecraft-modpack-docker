#!/bin/bash
# Check if a secret file contains non-comment text (not starting with #)
# Usage: check-secret-file.sh <file_path>
# Exit code 0: File has valid secret content
# Exit code 1: File does not exist, is empty, or only contains comments

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <file_path>" >&2
    exit 1
fi

FILE_PATH="$1"

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    exit 1
fi

# Check if file has size
if [ ! -s "$FILE_PATH" ]; then
    exit 1
fi

# Check if file has any non-comment, non-empty lines
# Read file line by line, skip empty lines and lines starting with #
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    if [ -z "$line" ]; then
        continue
    fi
    # Skip lines that start with # (with optional leading whitespace)
    if echo "$line" | grep -q '^\s*#'; then
        continue
    fi
    # If we get here, we found a non-comment line
    exit 0
done < "$FILE_PATH"

# No valid content found
exit 1
