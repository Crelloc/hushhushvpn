#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# make scripts executable
chmod +x $SCRIPT_DIR/*.sh

# Backup ssh config file or create one if it doesn't exist
cd $SCRIPT_DIR && cd ..

if [ -e "$PWD/config" ]; then
    cp "$PWD/config" "$PWD/config.bak"
else
    touch "$PWD/config"
fi

# Automate terraform commands to build infrastructure

terraform init -input=false && terraform plan -out=tfplan -input=false && terraform apply -input=false tfplan