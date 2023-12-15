#!/bin/bash

# Restore ssh config file and remove necessary files
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

cd $SCRIPT_DIR && cd ..

# Destroy instance

terraform destroy --auto-approve

rm -rf *.ovpn tfplan config* deleted_instance_info.txt .terraform* terraform.tfstate*

# Remove server from known hosts for encryption keys
# The commands below this comment line will auto-create.