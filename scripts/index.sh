#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# make scripts executable
chmod +x $SCRIPT_DIR/*.sh

# Backup ssh config file or create one if it doesn't exist

if [ -e "/home/$USER/.ssh/config" ]; then
    cp "/home/$USER/.ssh/config" "/home/$USER/.ssh/config.bak"
    cp "/home/$USER/.ssh/config" "/home/$USER/.ssh/config.bak3"
else
    touch "/home/$USER/.ssh/config" "/home/$USER/.ssh/config.bak" "/home/$USER/.ssh/config.bak3"
fi

# Automate terraform commands to build infrastructure
cd $SCRIPT_DIR && cd ..
terraform init -input=false && terraform plan -out=tfplan -input=false && terraform apply -input=false tfplan