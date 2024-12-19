#!/bin/bash

# Define default services.json file path
DEFAULT_SERVICES_FILE="./localstack-basic/res/services.json"

# Function to find the project/repo specific services.json file
find_services_file() {
  for file in $(find . -name "services.json"); do
    echo "$file"
    return
  done
  echo "No services.json file found. Using default: $DEFAULT_SERVICES_FILE" >&2
  echo "$DEFAULT_SERVICES_FILE"
}

# Function to find the .tf file containing 'provider "aws"'
find_entrypoint() {
  for file in $(find . -name "*.tf"); do
    if grep -q 'provider "aws"' "$file"; then
      echo "$file"
      return
    fi
  done
  echo "No .tf file containing 'provider \"aws\"' found." >&2
  exit 1
}

# Set ENTRYPOINT to the .tf file containing 'provider "aws"'
ENTRYPOINT=$(find_entrypoint)
# Set SERVICES_FILE to the found services.json file or default
SERVICES_FILE=$(find_services_file)
# Read services from services.json
SERVICES=$(jq -r '.[]' "$SERVICES_FILE")
# Set LocalStack endpoint
LOCALSTACK_ENDPOINT="http://localhost:4566"

# Generate endpoints block
ENDPOINTS=""
for SERVICE in $SERVICES; do
  ENDPOINTS+="    $SERVICE = \"$LOCALSTACK_ENDPOINT\"\n"
done

# Insert configuration flags and endpoints into main.tf
awk -v endpoints="$ENDPOINTS" '
  /provider "aws" \{/ {
    print
    print "  skip_credentials_validation = true"
    print "  skip_metadata_api_check     = true"
    print "  skip_requesting_account_id  = true"
    print endpoints
    next
  }
  { print }
' "$ENTRYPOINT" > "$ENTRYPOINT.tmp" && mv "$ENTRYPOINT.tmp" "$ENTRYPOINT"

# Print the contents of the modified main.tf file
echo "MAIN.TF:"
cat "$ENTRYPOINT"