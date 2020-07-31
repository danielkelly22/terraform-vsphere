terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust-vSphere"

    workspaces {
      name = "Linux_Test_Deployment"
    }
  }
}

provider "vsphere" {
  version        = "1.16.2"
  vim_keep_alive = 240
  user           = var.vsphere_user
  password       = var.vsphere_user_password
  vsphere_server = var.vsphere_server
  persist_session = true

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore_cluster" "linux_datastore_cluster" {
  name          = var.vsphere_linux_datastore_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data  "vsphere_compute_cluster" "linux_compute_cluster" {
  name            = var.vsphere_linux_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id 
}

data "vsphere_network" "app_dev_network" {
  name          = var.vsphere_app_dev_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "centos_template" {
  name             = var.vsphere_linux_machine_template
  datacenter_id    = data.vsphere_datacenter.dc.id
}


resource "vsphere_virtual_machine" "linux_test" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count_dev_linux_test
  name                     = "${var.vm_name_linux_test}${format("%02d", count.index+01)}"
  resource_pool_id         = data.vsphere_compute_cluster.linux_compute_cluster.resource_pool_id
  datastore_cluster_id     = data.vsphere_datastore_cluster.linux_datastore_cluster.id   
  folder                   = var.vsphere_linux_vm_folder 
  annotation		           = var.vm_annotation_1
  guest_id                 = data.vsphere_virtual_machine.centos_template.guest_id
  scsi_type                = data.vsphere_virtual_machine.centos_template.scsi_type
  num_cpus                 = 2
  memory                   = 2048
  network_interface {
            network_id    = data.vsphere_network.app_dev_network.id
            #adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_type[0]}"     
  }
  disk {      
      label     = "${var.vm_name_linux_test}_disk0.vmdk"
      size      = data.vsphere_virtual_machine.centos_template.disks.0.size      
      thin_provisioned = data.vsphere_virtual_machine.centos_template.disks.0.thin_provisioned
  }

  clone {
      template_uuid = data.vsphere_virtual_machine.centos_template.id
      timeout = "600"
      customize {
        linux_options {
          host_name = "${var.vm_name_linux_test}${format("%02d", count.index+01)}"
          domain = "amtrustservices.com"
        }
        network_interface {
            ipv4_address = "${var.vm_app_dev_ip_address}.${167 + count.index}"
            ipv4_netmask = "24"        
        }
        ipv4_gateway = "${var.vm_app_dev_ip_address}.1"
        dns_server_list = var.virtual_machine_dns_servers
        dns_suffix_list = ["amtrustservices.com", "serv.infr.it.amtrustna.com"]
        timeout = "600"       
      }
  }          
#Install PIP, WinRM and Ansible
  provisioner "remote-exec" {
    inline = [
      "yum install python3 -y"
      "python3 -m pip install --upgrade --force-reinstall pip",
      "pip3 install pyvmomi",
      "python3 -m pip install --upgrade pip",
      "pip3 install ansible",
      "ansible --version",
    ]
    connection {
      host     = self.default_ip_address
      type     = "ssh"
      user     = "root"
      password = var.centos_root_password
    }
  }

}