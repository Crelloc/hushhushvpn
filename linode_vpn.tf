variable "token" {}
variable "root_pass" {}
variable "ssh_key" {}
variable "ssh_private_key" {}
variable "group" {
  default = "Terraform"
}
variable "region" {
  default = "us-lax" #Los Angeles, CA
}
variable "label" {
  default = "linode-los-angeles-ca"
}
variable "image" {
  default = "linode/ubuntu22.04"
}
variable "type" {
  default = "g6-nanode-1"
}
variable "swap_size" {
  default = 1024
}

terraform {
    required_providers {
        linode = {
            source  = "linode/linode"
            version = "1.27.1"
        }
    }
}

provider "linode" {
    token = var.token
}

resource "linode_instance" "vpn_instance" {
    image           = var.image
    label           = var.label
    group           = var.group
    region          = var.region
    type            = var.type
    authorized_keys = [var.ssh_key]
    root_pass       = var.root_pass
    swap_size       = var.swap_size

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.ssh_private_key)}"
      host        = self.ip_address 
    }

    provisioner "file" {
      source      = ".env"
      destination = "/root/.env"
    }
    
    provisioner "file" {
      source      = "${var.ssh_private_key}.pub"
      destination = "/root/key.pub"
    }

    provisioner "file" {
      source      = "setup.sh"
      destination = "/root/setup.sh"
    }

    provisioner "file" {
      source      = "openvpn-install.sh"
      destination = "/root/openvpn-install.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "cat /etc/os-release",
        "chmod +x /root/setup.sh",
        "chmod +x /root/openvpn-install.sh"
      ]
    }

     provisioner "local-exec" {
      command = <<EOT
      
        ansible-playbook -u root -i '${self.ip_address},' \
        -e 'ansible_python_interpreter=/usr/bin/python3' \
        --private-key '${var.ssh_private_key}' \
        upgrade.yml 

      EOT
    }

    provisioner "local-exec" {
      command = <<EOT
        echo ""
        echo "creating/updating the ssh config file to include our new vpn server"
        echo "exporting env variables that sshConfig.sh will use"
        . ./.env
        export VPN_LABEL=${var.label}
        export VPN_IP=${self.ip_address}
        export PRIV_KEY_PATH=${var.ssh_private_key}
        
        chmod +x ./sshConfig.sh
        bash ./sshConfig.sh
        echo ""
        echo "you can now ssh into your vpn server using..."
        echo "ssh ${var.label}"
        echo "you can edit this file at: ~/.ssh/config"

        echo ""
        echo "building ./cleanup.sh script"
        echo "" >> ./cleanup.sh
        echo "ssh-keygen -f \"/home/$USER/.ssh/known_hosts\" -R \"${self.ip_address}\"" >> ./cleanup.sh
        chmod +x ./cleanup.sh
        echo ""
        echo "You can delete the server instance by executing:"
        echo "./cleanup.sh"
        echo ""
        echo "Note:"
        echo "You will need to manually delete your private and public keys in ~/.ssh/ folder"
        echo "...or reuse them."
       
      EOT
    }

}

