token           = "linode_api_token"
root_pass       = "root_password"
ssh_key         = "contents_of_public_key_file(.pub)"
ssh_private_key = "/path/to/private/key/filename"

### Uncomment below to override default values in linode_vpn.tf

#----------------------------------------------------------

## Labeling settings

#   default value for "label" is "linode-los-angeles-ca"
#   default value for "group" is "Terraform"


# label          = "linode-Sao-Paulo-Brazil"
# group          = "Terraform"


#----------------------------------------------------------

## Region settings

# default value is "us-lax" for Los Angeles, CA

# List of regions: view regions.json file or go to:
#   https://www.linode.com/docs/api/regions/

# region         = "br-gru"
           

#----------------------------------------------------------

## Image settings

# default value is "linode/ubuntu22.04" for Ubuntu Linux 22.04

# List of images: view images.json file or go to:
#   https://www.linode.com/docs/api/images/

#image          = "linode/ubuntu22.04"

#----------------------------------------------------------                 

## Type settings

# default value is "g6-nanode-1" for id found in types.json file
#  (i.e., 1 GB ram, 1 CPU)

# List of types: view types.json file or go to:
#   https://www.linode.com/docs/api/linode-types/


#type           = "g6-nanode-1"

#----------------------------------------------------------                 

## Swap settings

# default value is "1024" for 1GB

# (2048 max value) if 'type' has 2 GB or more ram)
# g6-nanode-1 has 1 GB of ram so max swap size is 1024

#swap_size      = "1024"

#----------------------------------------------------------

