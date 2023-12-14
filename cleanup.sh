#!/usr/bin/env bash

# Destroy instance
terraform destroy --auto-approve

# Restore ssh config file and remove necessary files

mv /home/$USER/.ssh/config.bak /home/$USER/.ssh/config

chmod -x ./*.sh

chmod +x ./index.sh

rm -f *.ovpn tfplan

# Remove server from known hosts for encryption keys
# The commands below this comment line will auto-create.
