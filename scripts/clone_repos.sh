#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it using your package manager." >&2
  exit 1
fi

# Specify the JSON file path
json_file="path/to/your/json/file.json"

# Iterate over the JSON array using jq
jq -c '.[]' "$json_file" | while IFS= read -r element; do
  # Process each element within the loop
  echo "Processing element:"
  echo "$element"

  git clone "$element"

  // run ck on element

  rm -rf ./"$element"

  # Perform any other operations or transformations as needed
done