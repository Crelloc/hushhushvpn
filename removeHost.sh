#!/bin/bash


echo 'Storing information about the instance to be deleted'
echo "Instance to be deleted host: $VPN_HOST" >> ./deleted_instance_info.txt
echo "Instance to be deleted hostname: $VPN_HOSTNAME" >> ./deleted_instance_info.txt
SSH_FILEPATH="/home/$USER/.ssh/config"
lineNum=$(grep -n -m 1 "$VPN_HOST" "$SSH_FILEPATH" | cut -d: -f1)
sum=$(expr $lineNum + 4)
lines="$lineNum,$sum"

if [ -z "$lineNum" ]; then
    echo "VPN_HOST: $VPN_HOST is not found in SSH_FILEPATH: $SSH_FILEPATH."
else
    echo "Deleting $VPN_HOST from $SSH_FILEPATH."
    sed -i "$lines"'d' "/home/$USER/.ssh/config"
    ssh-keygen -f /home/$USER/.ssh/known_hosts -R $VPN_HOSTNAME
    cp "/home/$USER/.ssh/config" "/home/$USER/.ssh/config.bak"
    rm -f "$VPN_HOST.ovpn"
fi
