import hcl2
import json

with open('../main.tf', 'r') as file:
    # Parse the HCL data from the main.tf file as a dictionary
    hcl_data = hcl2.load(file)
with open('res/services.json', 'r') as file:
    # Load the list of AWS services from the services.json file
    service_list = json.load(file)

# Convert the list of services to a tuple, as we won't be chjanging it
services = tuple(service_list)
# Define the LocalStack endpoint
localstack_endpoint = 'http://localhost:4566'

for provider in hcl_data.get('provider', []):
    if 'aws' in provider:
        provider['aws']['skip_metadata_api_check'] = 'true'
        provider['aws']['skip_credentials_validation'] = 'true'
        provider['aws']['skip_requesting_account_id'] = 'true'
        provider['aws']['endpoints'] = {service: localstack_endpoint for service in services}

# Write the modified HCL data back to a file
with open('modified_main.tf', 'w') as file:
    json.dump(hcl_data, file, indent=2)