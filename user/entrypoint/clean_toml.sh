#!/bin/bash

# ==============================================================================
# Script: clean_toml.sh
# Description: Strips all comments and empty lines from a TOML file for 
#              downstream processing or production-ready configuration.
# Usage: ./clean_toml.sh <input_file.toml> [output_file.toml]
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -e

# --- Argument Validation ---
if [[ -z "$1" ]]; then
    echo "Usage Error: Missing input file."
    echo "Syntax: $0 <source_file.toml> [destination_file.toml]"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-/dev/stdout}" # Default to stdout if no output file is provided

# --- Environment Checks ---
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Runtime Error: File '$INPUT_FILE' not found."
    exit 1
fi

# --- Core Logic: Data Extraction ---
# 1. Matches lines starting with '#' (including those with leading whitespace).
# 2. Matches empty or whitespace-only lines.
# 3. Uses 'grep -vE' to filter out these patterns, leaving only valid TOML keys/values.
grep -vE '^\s*#|^\s*$' "$INPUT_FILE" > "$OUTPUT_FILE"

# --- Clean Exit ---
if [[ "$OUTPUT_FILE" != "/dev/stdout" ]]; then
    echo "Success: Cleaned TOML written to $OUTPUT_FILE"
fi