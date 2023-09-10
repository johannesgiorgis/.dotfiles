#!/bin/env bash

# Convert Markdown files to MediaWiki files

echo 'hello'

input_file=$1
output_file="$(basename "$input_file" .md).mediawiki"

echo "Converting '${input_file}' to '${output_file}'..."

pandoc -f markdown -t mediawiki < "$input_file" > "$output_file"
