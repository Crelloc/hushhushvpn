#!/usr/bin/env bash

source /root/.env

username="$ENV_USER"
password="$ENV_PASSWORD"
auto_install="$AUTO_INSTALL"

if [ -z "$username" ] || [ -z "$password" ]; then
    echo "Error: ENV_USER or ENV_PASSWORD environment variables not set."
    exit 1
fi

useradd -m $username                                   && \
echo "$username:$password" | sudo chpasswd             && \
usermod -aG sudo $username -s /bin/bash                && \
echo "User $username created and added to sudo group"


cd "/home/$username"                          && \
cp /root/openvpn-install.sh .                  && \
chmod +x ./openvpn-install.sh                 && \
chown $username:$username ./openvpn-install.sh

if [ "$auto_install" == "y" ]; then
    ./openvpn-install.sh
    mv /root/$CLIENT.ovpn /home/$username/
else
    echo "AUTO_INSTALL is set to $auto_install in the .env configuration file."
    echo "You must run openvpn-install.sh manually on your VPN server."
    echo "The script is located in the directory: /home/$username/"
fi

# Adding public key to ssh authorized keys for new user

mkdir -p "/home/$username/.ssh"
chown $username:$username "/home/$username/.ssh"

cat /root/key.pub >> "/home/$username/.ssh/authorized_keys"
chown $username:$username "/home/$username/.ssh/authorized_keys"

# Disable root login

echo ""
echo "Disable root ssh login and disable ssh password login"

# Backup the original sshd_config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Update PasswordAuthentication
sed -i '/PasswordAuthentication/c\PasswordAuthentication no' /etc/ssh/sshd_config

# Update PermitRootLogin
sed -i '/PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config

# Restart SSH service 
systemctl restart sshd