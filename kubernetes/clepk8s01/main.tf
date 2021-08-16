terraform {
//  required_version = ">= 0.14.5"
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.0.2"
    }
  }

  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust-vSphere"

    workspaces {
      name = "terraform-vsphere--kubernetes-cledk8s06"
    }
  }
}
provider "vsphere" {
  vim_keep_alive = 240
  user           = var.vsphere_user
  password       = var.vsphere_user_password
  vsphere_server = var.vsphere_server
  persist_session = true

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter_name
}

data "vsphere_datastore_cluster" "cluster" {
  name          = var.vsphere_datastore_cluster_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data  "vsphere_compute_cluster" "cluster" {
  name            = var.vsphere_compute_cluster_name
  datacenter_id   = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "vm_template" {
  name             = var.vsphere_template_name
  datacenter_id    = data.vsphere_datacenter.datacenter.id
}

###

resource "vsphere_virtual_machine" "vm" {
  wait_for_guest_net_timeout = "30"
  count                    = var.number_of_nodes
  name                     = "${var.vm_name_prefix}${format("%s", element(var.alphabet_list, count.index))}"
  resource_pool_id         = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_cluster_id     = data.vsphere_datastore_cluster.cluster.id
  folder                   = var.vsphere_vm_folder_name
//  annotation		       = var.vm_annotation_1
  guest_id                 = data.vsphere_virtual_machine.vm_template.guest_id
  scsi_type                = data.vsphere_virtual_machine.vm_template.scsi_type
  num_cpus                 = 4
  memory                   = 16384
  network_interface {
    network_id    = data.vsphere_network.network.id
  }

  enable_disk_uuid = true
  disk {
    unit_number      = 0
    label            = "${var.vm_name_prefix}${format("%s", element(var.alphabet_list, count.index))}_disk0.vmdk"
    size             = data.vsphere_virtual_machine.vm_template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.vm_template.disks.0.thin_provisioned
  }

  disk {
    unit_number      = 1
    label            = "${var.vm_name_prefix}${format("%s", element(var.alphabet_list, count.index))}_disk1.vmdk"
    size             = 30
    thin_provisioned = true
  }

  clone {
      template_uuid = data.vsphere_virtual_machine.vm_template.id
      timeout = "900"
      customize {
        linux_options {
          host_name = "${var.vm_name_prefix}${format("%s", element(var.alphabet_list, count.index))}"
          domain = "amtrustservices.com"
        }
        network_interface {
            ipv4_address = element(var.vm_netplan_ip_address_list, count.index)
            ipv4_netmask = "24"
        }
        ipv4_gateway = var.vm_netplan_gateway
        dns_server_list = var.vm_netplan_nameservers
        dns_suffix_list = ["amtrustservices.com", "serv.infr.it.amtrustna.com"]
        timeout = "120"
      }
  }

#Install PIP, WinRM and Ansible
//  provisioner "remote-exec" {
//    inline = [
//      "yum install python3 -y",
//      "python3 -m pip install --upgrade --force-reinstall pip",
//      "pip3 install pyvmomi",
//      "python3 -m pip install --upgrade pip",
//      "pip3 install ansible",
//      "ansible --version",
//    ]
//    connection {
//      host     = self.default_ip_address
//      type     = "ssh"
//      user     = var.centos_root_user
//      password = var.centos_root_password
//    }
//  }

}