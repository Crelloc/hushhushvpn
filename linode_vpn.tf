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
  for_each        = { for inst in var.vpn_instances : inst.label => inst }
  image           = each.value.image
  label           = each.value.label
  group           = each.value.group
  region          = each.value.region
  type            = each.value.type
  swap_size       = each.value.swap_size
  authorized_keys = each.value.authorized_keys
  root_pass       = each.value.root_pass
}

resource "null_resource" "cleanup_script" {
  depends_on = [linode_instance.vpn_instance]

  for_each = { for inst in var.vpn_instances : inst.label => inst }

  triggers = {
    vpn_host     = each.key
    vpn_hostname = linode_instance.vpn_instance[each.key].ip_address
  }

  provisioner "local-exec" {
    when = destroy

    command = <<EOT
    ./scripts/lockScript.sh bash ./scripts/removeHost.sh
    EOT

    environment = {
      VPN_HOST     = "${self.triggers.vpn_host}"
      VPN_HOSTNAME = "${self.triggers.vpn_hostname}"
    }
  }
}

resource "null_resource" "setup_scripts" {
  for_each   = { for inst in var.vpn_instances : inst.label => inst }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(each.value.ssh_private_key)
    host        = linode_instance.vpn_instance[each.key].ip_address
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
    source      = "./scripts/setup.sh"
    destination = "/root/setup.sh"
  }

  provisioner "file" {
    source      = "./scripts/openvpn-install.sh"
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
        export ANSIBLE_CONFIG=./ansible/ansible.cfg

        ansible-playbook -u root -i '${linode_instance.vpn_instance[each.key].ip_address},' \
        -e 'ansible_python_interpreter=/usr/bin/python3' \
        -e 'client_name=${each.key}' \
        --private-key '${each.value.ssh_private_key}' \
        ./ansible/upgrade.yml

      EOT
  }

  provisioner "local-exec" {
    command = <<EOT

      . "${each.value.env_file_path}"
      export VPN_LABEL=${each.key}
      export CLIENT=${each.key}
      export VPN_IP=${linode_instance.vpn_instance[each.key].ip_address}
      export PRIV_KEY_PATH=${each.value.ssh_private_key}

      bash ./scripts/sshConfig.sh

      EOT
  }
}