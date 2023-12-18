#!/bin/bash

# Restore ssh config file and remove necessary files
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

cd $SCRIPT_DIR/..

# Destroy instance

terraform destroy --auto-approve

rm -rf login tfplan deleted_instance_info.txt .terraform* terraform.tfstate*