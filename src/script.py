import hcl
import json

override_path = './localstack-basic/res/override.tf'
with open(override_path, 'r') as file:
    # Parse the HCL data from the main.tf file as a dictionary
    override = hcl.load(file)
with open('./localstack-basic/res/services.json', 'r') as file:
    # Load the list of AWS services from the services.json file
    service_list = json.load(file)
# Convert the list of services to a tuple, as we won't be chjanging it
services = tuple(service_list)
# Define the LocalStack endpoint
localstack_endpoint = 'http://localhost:4566'

# Modify the endpoints block in the AWS provider section
override['provider'][0]['aws']['endpoints'] = {service: localstack_endpoint for service in service_list}

# Convert the modified data back to HCL format
override_string = hcl.dumps(override)

# Write the modified HCL data back to a file
with open(override_path, 'w') as file:
    file.write(override_string)

# Print the contents of the modified_main.tf file
with open(override_path, 'r') as file:
    print(f'OVERRIDE.TF:\n{file.read()}')
