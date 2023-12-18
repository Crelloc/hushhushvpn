#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# make scripts executable
chmod +x $SCRIPT_DIR/*.sh

# Backup ssh config file or create one if it doesn't exist
cd $SCRIPT_DIR/../
mkdir login

if [ -e "$PWD/login/config" ]; then
    cp "$PWD/login/config" "$PWD/login/config.bak"
else
    touch "$PWD/login/config"
fi

# Automate terraform commands to build infrastructure

terraform init -input=false && terraform plan -out=tfplan -input=false && terraform apply -input=false tfplan