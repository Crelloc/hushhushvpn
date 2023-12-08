
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
      env_file_path   = "./.env-linode-miami"
    },
    {
      image           = "linode/ubuntu22.04"
      label           = "linode-washington-dc-us"
      group           = "Terraform"
      region          = "us-iad"
      type            = "g6-nanode-1"
      swap_size       = 2048
      vpn_client_name = "linode-washington-dc-us"
      env_file_path   = "./.env-linode-dc"
    },
    {
      image           = "linode/ubuntu22.04"
      label           = "linode-fremont-ca-us"
      group           = "Terraform"
      region          = "us-west"
      type            = "g6-standard-1"
      swap_size       = 2048
      vpn_client_name = "linode-fremont-ca-us"
      env_file_path   = "./.env-linode-fremont"
    },
  ]
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
    count           = length(var.vpn_instances)
    image           = var.vpn_instances[count.index]["image" ]
    label           = var.vpn_instances[count.index]["label" ]
    group           = var.vpn_instances[count.index]["group" ]
    region          = var.vpn_instances[count.index]["region"]
    type            = var.vpn_instances[count.index]["type"  ]
    authorized_keys = var.vpn_instances_keys[count.index]["authorized_keys"]
    root_pass       = var.vpn_instances_keys[count.index]["root_pass"]
    swap_size       = var.vpn_instances[count.index]["swap_size"]

    provisioner "local-exec" {
      when = destroy
      command = <<EOT
        echo 'Removing Host: ${self.ip_address} from ssh config file'
      EOT
    }
  }

    # connection {
    #   type        = "ssh"
    #   user        = "root"
    #   private_key = "${file(var.vpn_instances_keys[count.index]["ssh_private_key"])}"
    #   host        = self.ip_address
    # }

    # provisioner "file" {
    #   source      = "${var.vpn_instances[count.index]["env_file_path"]}"
    #   destination = "/root/.env"
    # }
    
    # provisioner "file" {
    #   source      = "${var.vpn_instances_keys[count.index]["ssh_private_key"]}.pub"
    #   destination = "/root/key.pub"
    # }

    # provisioner "file" {
    #   source      = "setup.sh"
    #   destination = "/root/setup.sh"
    # }

    # provisioner "file" {
    #   source      = "openvpn-install.sh"
    #   destination = "/root/openvpn-install.sh"
    # }

    # provisioner "remote-exec" {
    #   inline = [
    #     "cat /etc/os-release",
    #     "chmod +x /root/setup.sh",
    #     "chmod +x /root/openvpn-install.sh"
    #   ]
    # }

    #  provisioner "local-exec" {
    #   command = <<EOT
      
    #     ansible-playbook -u root -i '${self.ip_address},' \
    #     -e 'ansible_python_interpreter=/usr/bin/python3' \
    #     -e 'client_name=${var.vpn_instances[count.index]["vpn_client_name"]}' \
    #     --private-key '${var.vpn_instances_keys[count.index]["ssh_private_key"]}' \
    #     upgrade.yml

    #   EOT
    # }

    # provisioner "local-exec" {
    #   command = <<EOT
    #     echo ""
    #     echo "creating/updating the ssh config file to include our new vpn server"
    #     echo "exporting env variables that sshConfig.sh will use"
    #     . "${var.vpn_instances[count.index]["env_file_path"]}"
    #     export VPN_LABEL=${var.vpn_instances[count.index]["label"]}
    #     export CLIENT=${var.vpn_instances[count.index]["vpn_client_name"]}
    #     export VPN_IP=${self.ip_address}
    #     export PRIV_KEY_PATH=${var.vpn_instances_keys[count.index]["ssh_private_key"]}
        
    #     chmod +x ./sshConfig.sh
    #     bash ./sshConfig.sh
    #     echo ""
    #     echo "you can now ssh into your vpn server using..."
    #     echo "ssh ${var.vpn_instances[count.index]["label"]}"
    #     echo "you can edit this file at: ~/.ssh/config"

    #     echo ""
    #     echo "building ./cleanup.sh script"
    #     echo "" >> ./cleanup.sh
    #     echo "ssh-keygen -f \"/home/$USER/.ssh/known_hosts\" -R \"${self.ip_address}\"" >> ./cleanup.sh
    #     chmod +x ./cleanup.sh
    #     echo ""
    #     echo "You can delete the server instance by executing:"
    #     echo "./cleanup.sh"
    #     echo ""
    #     echo "Note:"
    #     echo "You will need to manually delete your private and public keys in ~/.ssh/ folder"
    #     echo "...or reuse them."
       
    #   EOT
    # }

}


resource "null_resource" "cleanup_script" {
  # This resource is used only to capture information before deletion
  depends_on = [linode_instance.vpn_instance]

  count = length(var.vpn_instances)
  triggers = {
    vpn_host = var.vpn_instances[count.index]["vpn_client_name" ]
    vpn_hostname = linode_instance.vpn_instance[count.index].ip_address
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      echo 'Storing information about the instance to be deleted'
      echo "Instance to be deleted host: $VPN_HOST" >> ./deleted_instance_info.txt
      echo "Instance to be deleted hostname: $VPN_HOSTNAME" >> ./deleted_instance_info.txt
    EOT
     environment = {
      VPN_HOST = "${self.triggers.vpn_host}",
      VPN_HOSTNAME = "${self.triggers.vpn_hostname}",
    }
  }
}
