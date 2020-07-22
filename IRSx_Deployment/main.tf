terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust-vSphere"

    workspaces {
      name = "IRSx_Deployment"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_admin_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = var.vsphere_datastore_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data  "vsphere_compute_cluster" "db_cluster" {
  name            = var.vsphere_db_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id 
}

data  "vsphere_compute_cluster" "dev_db_cluster" {
  name            = var.vsphere_dev_db_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id 
}

data  "vsphere_compute_cluster" "compute_cluster" {
  name            = var.vsphere_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "web_dev_network" {
  name          = var.vsphere_web_dev_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "db_dev_network" {
  name          = var.vsphere_db_dev_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "app_dev_network" {
  name          = var.vsphere_app_dev_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "web_prod_network" {
  name          = var.vsphere_web_prod_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "db_prod_network" {
  name          = var.vsphere_db_prod_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "app_prod_network" {
  name          = var.vsphere_app_prod_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name             = var.vsphere_machine_template
  datacenter_id    = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "db_template" {
  name             = var.vsphere_db_machine_template
  datacenter_id    = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm_db_01" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count_dev_DB
  name                     = "${var.vm_name_DB}${format("%02d", count.index+01)}"
  resource_pool_id         = data.vsphere_compute_cluster.dev_db_cluster.resource_pool_id
   datastore_cluster_id    = data.vsphere_datastore_cluster.datastore_cluster.id   
  folder                   = var.vsphere_db_vm_folder 
  annotation		           = var.vm_annotation
  guest_id                 = data.vsphere_virtual_machine.db_template.guest_id
  scsi_type                = data.vsphere_virtual_machine.db_template.scsi_type
  num_cpus                 = 12
  memory                   = 122880
  firmware                 = "efi"
  efi_secure_boot_enabled  = true
  nested_hv_enabled        = true
  network_interface {
            network_id    = data.vsphere_network.db_dev_network.id
            #adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_type[0]}"     
  }
  disk {      
      label     = "${var.vm_name_DB}${format("%02d", count.index+00)}.vmdk"
      size      = data.vsphere_virtual_machine.db_template.disks.0.size      
      thin_provisioned = data.vsphere_virtual_machine.db_template.disks.0.thin_provisioned
  }
  
  disk {      
      label     = "${var.vm_name_DB_rep}${format("%02d", count.index+01)}.vmdk"
      size      = data.vsphere_virtual_machine.db_template.disks.1.size      
      thin_provisioned = data.vsphere_virtual_machine.template.disks.1.thin_provisioned
  }
  
  clone {
      template_uuid = data.vsphere_virtual_machine.db_template.id
      timeout = "600"
      customize {
        windows_options {
            computer_name         = "${var.vm_name_DB}${format("%02d", count.index+01)}"
            join_domain           = var.domain_name
            domain_admin_user     = var.windows_admin_account
            domain_admin_password = var.windows_admin_password
            admin_password        = var.local_admin_password
        }
        network_interface {
            ipv4_address = "${var.vm_db_dev_ip_address}.${27 + count.index}"
            ipv4_netmask = "24"
            dns_server_list = var.virtual_machine_dns_servers          
        }
        ipv4_gateway = "${var.vm_db_dev_ip_address}.1" 
        timeout = "600"       
      }
  }          

}

resource "vsphere_virtual_machine" "vm_db_rep_01" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count_dev_DB_rep
  name                     = "${var.vm_name_DB_rep}${format("%02d", count.index+01)}"
  resource_pool_id         = data.vsphere_compute_cluster.dev_db_cluster.resource_pool_id
   datastore_cluster_id    = data.vsphere_datastore_cluster.datastore_cluster.id   
  folder                   = var.vsphere_db_vm_folder
  annotation		           = var.vm_annotation
  guest_id                 = data.vsphere_virtual_machine.db_template.guest_id
  scsi_type                = data.vsphere_virtual_machine.db_template.scsi_type
  num_cpus                 = 12
  memory                   = 122880
  firmware                 = "efi"
  efi_secure_boot_enabled  = true
  nested_hv_enabled        = true
  network_interface {
            network_id    = data.vsphere_network.db_dev_network.id
            #adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_type[0]}"     
  }
  disk {      
      label     = "${var.vm_name_DB_rep}${format("%02d", count.index+00)}.vmdk"
      size      = data.vsphere_virtual_machine.db_template.disks.0.size      
      thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  
  clone {
      template_uuid = data.vsphere_virtual_machine.db_template.id
      timeout = "600"
      customize {
        windows_options {
            computer_name         = "${var.vm_name_DB_rep}${format("%02d", count.index+01)}"
            join_domain           = var.domain_name
            domain_admin_user     = var.windows_admin_account
            domain_admin_password = var.windows_admin_password
            admin_password        = var.local_admin_password
        }
        network_interface {
            ipv4_address = "${var.vm_db_dev_ip_address}.${28 + count.index}"
            ipv4_netmask = "24"
            dns_server_list = var.virtual_machine_dns_servers          
        }
        ipv4_gateway = "${var.vm_db_dev_ip_address}.1" 
        timeout = "600"       
      }
  }          

}
