#!/bin/bash

# Define file paths
ENTRYPOINT="./main.tf"
SERVICES_FILE="./localstack-basic/res/services.json"
LOCALSTACK_ENDPOINT="http://localhost:4566"

# Read services from services.json
SERVICES=$(jq -r '.[]' "$SERVICES_FILE")

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
    next
  }
  /endpoints \{/ {
    print
    print endpoints
    next
  }
  { print }
' "$ENTRYPOINT" > "$ENTRYPOINT.tmp" && mv "$ENTRYPOINT.tmp" "$ENTRYPOINT"

# Print the contents of the modified main.tf file
echo "MAIN.TF:"
cat "$ENTRYPOINT"