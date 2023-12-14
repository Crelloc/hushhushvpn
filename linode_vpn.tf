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
  for_each = { for inst in var.vpn_instances : inst.label => inst }
  image           = each.value.image
  label           = each.value.label
  group           = each.value.group
  region          = each.value.region
  type            = each.value.type
  swap_size       = each.value.swap_size
  authorized_keys = each.value.authorized_keys
  root_pass       = each.value.root_pass

    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(each.value.ssh_private_key)
      host        = self.ip_address
    }

    provisioner "file" {
      source      = each.value.env_file_path
      destination = "/root/.env"
    }

    provisioner "file" {
      source      = "${each.value.ssh_private_key}.pub"
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
        -e 'client_name=${self.label}' \
        --private-key '${each.value.ssh_private_key}' \
        upgrade.yml

      EOT
    }

    provisioner "local-exec" {
      command = <<EOT
      echo ""
      echo "creating/updating the ssh config file to include our new vpn server"
      echo "exporting env variables that sshConfig.sh will use"
      . "${each.value.env_file_path}"
      export VPN_LABEL=${self.label}
      export CLIENT=${self.label}
      export VPN_IP=${self.ip_address}
      export PRIV_KEY_PATH=${each.value.ssh_private_key}

      chmod +x ./sshConfig.sh
      bash ./sshConfig.sh
      echo ""
      echo "you can now ssh into your vpn server using..."
      echo "ssh ${self.label}"
      echo "you can edit this file at: ~/.ssh/config"

      echo ""
      echo "building ./cleanup.sh script"
      echo "# ${self.label}:" >> ./cleanup.sh
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

resource "null_resource" "cleanup_script" {
  for_each = { for inst in var.vpn_instances : inst.label => inst }

  depends_on = [linode_instance.vpn_instance]

  triggers = {
    vpn_host     = each.value.label
    vpn_hostname = linode_instance.vpn_instance[each.value.label].ip_address
  }

  provisioner "local-exec" {
    when = destroy

    command = <<EOT
    bash ./removeHost.sh
    EOT

    environment = {
      VPN_HOST = "${self.triggers.vpn_host}"
      VPN_HOSTNAME = "${self.triggers.vpn_hostname}"
    }
  }
}
