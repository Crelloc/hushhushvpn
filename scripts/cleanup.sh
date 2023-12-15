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
# linode-washington-dc-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.234.38.50"
# linode-miami-florida-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.189.167"
# linode-fremont-ca-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "23.239.22.234"
# linode-washington-dc-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.195.23"
# linode-miami-florida-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.186.243"
# linode-fremont-ca-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "45.79.77.130"
# linode-washington-dc-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.238.35"
# linode-fremont-ca-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "23.239.22.234"
# linode-miami-florida-us:
ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.162.196"
