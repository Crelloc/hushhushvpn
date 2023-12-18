#!/bin/bash

#Best practice to define variables define variables at the top of functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
ssh_config_file="$PWD/login/config"
vpn_label="$VPN_LABEL"
ip_address="$VPN_IP"
priv_key_path="$PRIV_KEY_PATH"
username="$ENV_USER"
client_name="$CLIENT"
auto_install="$AUTO_INSTALL"

content_to_prepend="
Host $vpn_label
	User $username
  	Port 22
  	IdentityFile $priv_key_path
	HostName $ip_address
"

cd $SCRIPT_DIR/../

echo ""
echo "creating/updating the ssh config file to include our new vpn server"

# Check if the file exists
if [ -e "$ssh_config_file" ]; then
    echo "File $ssh_config_file already exists. appending content."

    # Prepend content to the file
    echo -e "$content_to_prepend" >> "$ssh_config_file"
    
    echo "Content prepended successfully."
else
    # Create the file and add contents
    echo -e "$content_to_prepend" > "$ssh_config_file"

    echo "File $ssh_config_file created successfully."
fi



if [ "$auto_install" == "y" ]; then
    # Download your vpn configuration file
    scp -F ./login/config "$vpn_label:/home/$username/$client_name.ovpn" ./login

    echo ""
    echo "You can now use your $client_name.ovpn file
     to connect to your vpn server.

    Make sure to configure your network settings to use your
    $client_name.ovpn file.

    $client_name.ovpn is located in:

    $PWD/login/$client_name.ovpn"

fi

echo ""
echo "you can now ssh into your vpn server using..."
echo "ssh -F $PWD/$LOGIN_FOLDER_NAME $client_name"