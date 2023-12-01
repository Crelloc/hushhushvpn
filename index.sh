#!/usr/bin/env bash

# make scripts executable
chmod +x *.sh

# Backup ssh config file or create one if it doesn't exist

if [ -e "/home/$USER/.ssh/config" ]; then
    cp "/home/$USER/.ssh/config" "/home/$USER/.ssh/config.bak"
else
    touch "/home/$USER/.ssh/config" "/home/$USER/.ssh/config.bak"
fi

# Automate terraform commands to build infrastructure

terraform init -input=false && terraform plan -out=tfplan -input=false && terraform apply -input=false tfplan