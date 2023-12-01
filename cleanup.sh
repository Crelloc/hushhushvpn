#!/usr/bin/env bash

# Destroy instance
terraform destroy <<EOF
yes
EOF

# Restore ssh config file and remove necessary files

mv /home/$USER/.ssh/config.bak /home/$USER/.ssh/config

chmod -x ./*.sh

chmod +x ./index.sh

rm -f *.ovpn tfplan

# Remove server from known hosts for encryption keys
# The commands below this comment line will auto-create.


ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.157.155"

ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.136.161"

ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.24.45"

ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.157.155"

ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.155.112"

ssh-keygen -f "/home/crelloc/.ssh/known_hosts" -R "172.233.155.207"
