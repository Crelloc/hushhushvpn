# hushhushvpn
Open VPN automation using Terraform, Ansible, and Linode's cloud platform

Converted [Angristan's](https://github.com/angristan/openvpn-install) VPN script to IaC

Developed on Linux Mint 21.1 but should run on Linux and MAC

### Getting started

- Sign up for Linode if you haven't already
    - https://www.linode.com/
    - Generate an api token
        - https://www.linode.com/docs/products/tools/api/guides/manage-api-tokens/
- Install terraform
    - https://developer.hashicorp.com/terraform/install
- Install ansible
    - https://docs.ansible.com/ansible/2.9/installation_guide/intro_installation.html
- Install git:
    - https://git-scm.com/downloads

- Generate an ssh private and public key on your local machine
    - Follow prompt to name and save keys to a folder location
        - Create an **EMPTY PASSPHRASE** 
        - https://docs.acquia.com/cloud-platform/manage/ssh/getting-started-ssh/generate/

```
 ssh-keygen -t rsa -b 4096

```

- Modify [variables.tf](variables.tf) for *your linode api token, root_pass, ssh_key, and ssh_private_key file path, etc.*

```
variable "token" {
    default = "linode_api_token"
}

variable "vpn_instances" {
  default = [
    {
      image           = "linode/ubuntu22.04"
      label           = "linode-miami-florida-us"
      group           = "Terraform"
      region          = "us-mia"
      type            = "g6-standard-1"
      swap_size       = 2048
      vpn_client_name = "linode-miami-florida-us"
      env_file_path   = "./env/.env-linode-miami"
      authorized_keys = ["contents of public key. ex: cat linode_terraform_vpn_id_rsa.pub"]
      ssh_private_key = "/home/user/.ssh/linode_terraform_vpn_id_rsa"
      root_pass       = "TebK6CWUPkgLQZ8"
    },
   ...
  ]
}
 
```

- Modify [env/](env/) files for server configuration setting: *ENV_USER, ENV_PASSWORD, etc*
    - you can override other default variables for further customization

```
export ENV_USER="user"
export ENV_PASSWORD="password"
 ...
```

##### Download and run [./scripts/index.sh](scripts/index.sh) script:

```
 git clone https://github.com/Crelloc/linodevpn.git
```
```
chmod +x ./linodevpn/scripts/index.sh
```
```
cd ./linodevpn
```
```
./scripts/index.sh
```

- After the build is done, you should have vpn file(s) (.ovpn) in the login folder of this project's directory.
- You can also remote login into your vpn server using the ssh config file located in the login folder:
```
ssh -F ./login/config "name_of_host_that's_listed_in_config"
```

### Set up your device/ computer to connect to vpn server
- Import the .ovpn file in your network settings or download openvpn connect: https://openvpn.net/client/

### Features

- Creates a vpn using OpenVPN with IPV6 support and no logging of web history
- Automates user creation and disables root login and password login
for better security.
- Updates the ssh config file to automate ssh login
- Automatically downloads a .ovpn file (client config file for vpn)


### TODO

- ~~Modify terraform files to support multiple instance~~
    - ~~for example, any change to the terraform files will destroy the previous infrastructure~~
- Add other cloud providers: AWS, Azure, etc
- Scale VPN server with kubernetes

### Linode's Docs

```
https://registry.terraform.io/providers/linode/linode/1.27.1/docs
https://www.linode.com/docs/api/
```

### Available Linode instance types

```
curl https://api.linode.com/v4/linode/types
```

### Available Linode instance images

```
curl https://api.linode.com/v4/images
```

### Available Linode instance Regions

```
curl https://api.linode.com/v4/regions | grep -oP '"label": "\K[^"]*|"id": "\K[^"]*' | paste -d':' - -

```

### Terraform Commands

```
terraform init

terraform plan

terraform apply

# All in one command:
terraform init -input=false && terraform plan -out=tfplan -input=false && terraform apply -input=false tfplan

terraform destroy
```


### References

#### Linode Max Swap
```
https://www.linode.com/community/questions/9449/swap-resize-via-linode-manager
```

#### Terraform Secrets Management
```
https://www.linode.com/docs/guides/secrets-management-with-terraform/
```

#### OpenVPN Hardware Requirements
```
https://openvpn.net/vpn-server-resources/openvpn-access-server-system-requirements/#hardware-requirements
```
