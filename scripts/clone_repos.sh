#!/bin/bash

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
  echo "Error: jq is not installed. Please install it using your package manager." >&2
  exit 1
fi

json_file="./output_repos/repos.json"

jq -c '.[]' "$json_file" | while IFS= read -r element; do
  echo "Processing element:"
  url=$(echo "$element" | jq -r .sshUrl)
  name=$(echo "$element" | jq -r .nameWithOwner)

  ssh-add -l
  git clone -q "$url"

  java -jar ck-0.7.1-SNAPSHOT-jar-with-dependencies.jar ./"$name" true 0 true ./data_analysis

  rm -rf ./"$name"
done
