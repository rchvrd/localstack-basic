import hcl
import json

with open('main.tf', 'r') as file:
    # Parse the HCL data from the main.tf file as a dictionary
    hcl_data = hcl.load(file)
with open('./localstack-basic/res/services.json', 'r') as file:
    # Load the list of AWS services from the services.json file
    service_list = json.load(file)

# Convert the list of services to a tuple, as we won't be chjanging it
services = tuple(service_list)
# Define the LocalStack endpoint
localstack_endpoint = 'http://localhost:4566'

for provider in hcl_data.get('provider', []):
    if 'aws' in provider:
        provider['aws']['skip_metadata_api_check'] = True
        provider['aws']['skip_credentials_validation'] = True
        provider['aws']['skip_requesting_account_id'] = True
        provider['aws']['endpoints'] = {service: localstack_endpoint for service in services}

# Convert the modified data back to HCL format
hcl_string = hcl.dumps(hcl_data)

# Write the modified HCL data back to a file
with open('main.tf', 'w') as file:
    file.write(hcl_string)

# Print the contents of the modified_main.tf file
with open('main.tf', 'r') as file:
    print(f'MAIN.TF:\n{file.read()}')
