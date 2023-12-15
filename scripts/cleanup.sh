#!/bin/bash

# Destroy instance
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

cd $SCRIPT_DIR && cd ..
terraform destroy --auto-approve

# Restore ssh config file and remove necessary files

mv /home/$USER/.ssh/config.bak /home/$USER/.ssh/config

rm -f *.ovpn tfplan

# Remove server from known hosts for encryption keys
# The commands below this comment line will auto-create.
