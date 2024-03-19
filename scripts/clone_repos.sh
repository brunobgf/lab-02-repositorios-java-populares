#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it using your package manager." >&2
  exit 1
fi

json_file="path/to/your/json/file.json"

jq -c '.[]' "$json_file" | while IFS= read -r element; do
  echo "Processing element:"
  echo "$element"

  git clone "$element"

  java -jar ck-0.7.1-SNAPSHOT-jar-with-dependencies.jar ./"$element" true 0 true ./data_analysis

  rm -rf ./"$element"
done