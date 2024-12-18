#!/bin/bash

# Define file paths
OVERRIDE_FILE="./localstack-basic/res/override.tf"
SERVICES_FILE="./localstack-basic/res/services.json"
LOCALSTACK_ENDPOINT="http://localhost:4566"

# Read services from services.json
SERVICES=$(jq -r '.[]' "$SERVICES_FILE")

# Generate endpoints block
ENDPOINTS=""
for SERVICE in $SERVICES; do
  ENDPOINTS+="    $SERVICE = \"$LOCALSTACK_ENDPOINT\"\n"
done

# Insert endpoints into override.tf
awk -v endpoints="$ENDPOINTS" '
  /endpoints \{/ {
    print
    print endpoints
    next
  }
  { print }
' "$OVERRIDE_FILE" > "$OVERRIDE_FILE.tmp" && mv "$OVERRIDE_FILE.tmp" "$OVERRIDE_FILE"

# Print the contents of the modified override.tf file
echo "OVERRIDE.TF:"
cat "$OVERRIDE_FILE"