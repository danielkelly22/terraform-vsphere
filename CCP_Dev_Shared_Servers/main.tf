terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust-vSphere"

    workspaces {
      name = "CCP_Dev_Shared_Servers"
    }
  }
}

provider "vsphere" {
  version        = "1.16.2"
  vim_keep_alive = 240
  user           = var.vsphere_user
  password       = var.vsphere_admin_password
  vsphere_server = var.vsphere_server
  persist_session = true

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

data  "vsphere_compute_cluster" "compute_cluster" {
  name            = var.vsphere_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "SSAS_network" {
  name          = var.vsphere_SSAS_dev_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "SSIS_network" {
  name          = var.vsphere_SSIS_dev_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "db_template" {
  name             = var.vsphere_db_machine_template
  datacenter_id    = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm_SSAS_01" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count_dev_SSAS
  name                     = "${var.vm_name_SSAS}${format("%02d", count.index+01)}"
  resource_pool_id         = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_cluster_id    = data.vsphere_datastore_cluster.datastore_cluster.id   
  folder                   = var.vsphere_SSAS_vm_folder 
  annotation		           = var.vm_annotation
  guest_id                 = data.vsphere_virtual_machine.db_template.guest_id
  scsi_type                = data.vsphere_virtual_machine.db_template.scsi_type
  num_cpus                 = 4
  memory                   = 32768
  firmware                 = "efi"
  efi_secure_boot_enabled  = true
  nested_hv_enabled        = true
  network_interface {
            network_id    = data.vsphere_network.SSAS_network.id
            #adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_type[0]}"     
  }
  disk {      
      label     = "${var.vm_name_SSAS}_disk0.vmdk"
      size      = data.vsphere_virtual_machine.db_template.disks.0.size      
      thin_provisioned = data.vsphere_virtual_machine.db_template.disks.0.thin_provisioned
  }

  clone {
      template_uuid = data.vsphere_virtual_machine.db_template.id
      timeout = "600"
      customize {
        windows_options {
            computer_name         = "${var.vm_name_SSAS}${format("%02d", count.index+01)}"
            join_domain           = var.domain_name
            domain_admin_user     = var.windows_admin_account
            domain_admin_password = var.windows_admin_password
            admin_password        = var.local_admin_password
        }
        network_interface {
            ipv4_address = "${var.vm_SSAS_dev_ip_address}.${27 + count.index}"
            ipv4_netmask = "24"
            dns_server_list = var.virtual_machine_dns_servers          
        }
        ipv4_gateway = "${var.vm_SSAS_dev_ip_address}.1" 
        timeout = "600"       
      }
  }          

}

resource "vsphere_virtual_machine" "vm_SSIS_01" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count_dev_SSIS
  name                     = "${var.vm_SSIS_01}${format("%02d", count.index+01)}"
  resource_pool_id         = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_cluster_id    = data.vsphere_datastore_cluster.datastore_cluster.id   
  folder                   = var.vsphere_SSIS_vm_folder
  annotation		           = var.vm_annotation
  guest_id                 = data.vsphere_virtual_machine.db_template.guest_id
  scsi_type                = data.vsphere_virtual_machine.db_template.scsi_type
  num_cpus                 = 4
  memory                   = 32768
  firmware                 = "efi"
  efi_secure_boot_enabled  = true
  nested_hv_enabled        = true
  network_interface {
            network_id    = data.vsphere_network.SSIS_network.id
            #adapter_type  = "${data.vsphere_virtual_machine.template.network_interface_type[0]}"     
  }
  disk {      
      label     = "${var.vm_SSIS_01}_disk0.vmdk"
      size      = data.vsphere_virtual_machine.db_template.disks.0.size      
      thin_provisioned = data.vsphere_virtual_machine.db_template.disks.0.thin_provisioned
  }
  
  clone {
      template_uuid = data.vsphere_virtual_machine.db_template.id
      timeout = "600"
      customize {
        windows_options {
            computer_name         = "${var.vm_SSIS_01}${format("%02d", count.index+01)}"
            join_domain           = var.domain_name
            domain_admin_user     = var.windows_admin_account
            domain_admin_password = var.windows_admin_password
            admin_password        = var.local_admin_password
        }
        network_interface {
            ipv4_address = "${var.vm_SSIS_dev_ip_address}.${28 + count.index}"
            ipv4_netmask = "24"
            dns_server_list = var.virtual_machine_dns_servers          
        }
        ipv4_gateway = "${var.vm_SSIS_dev_ip_address}.1" 
        timeout = "600"       
      }
  }          

}
