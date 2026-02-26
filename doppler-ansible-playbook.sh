#!/bin/bash

# Update playbook before running
just update

TEMP_VARS=$(mktemp)
trap "rm -f '$TEMP_VARS'" EXIT

doppler setup --no-interactive

# Download secrets and convert to Ansible-compatible format
# The jq filter:
# 1. Converts all keys to lowercase
# 2. Ensures values are properly JSON-encoded to prevent escape sequence issues
doppler secrets download --format=json --no-file |
  jq 'walk(
    if type == "object" then 
      with_entries(.key |= ascii_downcase)
    else 
      .
    end
  )' > "$TEMP_VARS"

# Check if the JSON is valid before proceeding
if ! jq empty "$TEMP_VARS" 2>/dev/null; then
  echo "Error: Invalid JSON from Doppler" >&2
  exit 1
fi

# Run ansible-playbook with the temporary file
if [ -z "$1" ]; then
  echo "Usage: $0 <tags>" >&2
  echo "Example: $0 setup-all,start" >&2
  exit 1
fi

ansible-playbook --extra-vars "@${TEMP_VARS}" --inventory inventory/hosts setup.yml --tags="$1"
