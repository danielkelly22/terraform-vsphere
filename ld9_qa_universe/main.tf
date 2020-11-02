provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_user_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore_cluster" "datastore" {
  name          = var.vsphere_datastore_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data  "vsphere_compute_cluster" "cluster" {
  name            = var.vsphere_compute_cluster
  datacenter_id   = data.vsphere_datacenter.dc.id 
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name             = var.vsphere_machine_template
  datacenter_id    = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  wait_for_guest_net_timeout = "15"
  count                    = var.vm_count
  name                     = "${var.vm_name}"
  resource_pool_id         = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_cluster_id     = data.vsphere_datastore_cluster.datastore.id 
  folder                   = var.vsphere_vm_folder 
  annotation		           = var.vm_annotation
  guest_id                 = data.vsphere_virtual_machine.template.guest_id
  scsi_type                = data.vsphere_virtual_machine.template.scsi_type
  num_cpus                 = 4
  memory                   = 16384
  network_interface {
            network_id    = data.vsphere_network.network.id
            #adapter_type  = data.vsphere_virtual_machine.template.network_interface_type[0]
  }
  disk {      
    label            = "${var.vm_name}_disk01.vmdk"
    size             = data.vsphere_virtual_machine.template.disks.0.size    
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  disk {      
    label 	         = "${var.vm_name}_disk02.vmdk"
    size             = "400"   
    unit_number      = 1
    thin_provisioned = true
  }
  
  clone {
      template_uuid = data.vsphere_virtual_machine.template.id
      timeout = "600"
      customize {
        linux_options {
          host_name = "${var.vm_name}"
          domain = "amtrustservices.com"
        }
        network_interface {
            ipv4_address = "10.94.8.35"
            ipv4_netmask = "22"        
        }
        ipv4_gateway = "10.94.8.1"
        dns_server_list = var.virtual_machine_dns_servers
        dns_suffix_list = ["amtrustservices.com", "serv.infr.it.amtrustna.com"]
        timeout = "600"       
      }
  }          

}

# resource "null_resource" "vsphere_apache_setup" {
#   count                    = var.vm_count
#   triggers = {
#     policy_sha1 = "${sha1(file("./files/install_apache.sh"))}"
#   }
#   provisioner "file" {
#     source = "./files/install_apache.sh"
#     destination = "/tmp/install_apache.sh"

#     connection {
#     host     = vsphere_virtual_machine.vm_01[count.index].default_ip_address
#     type     = "ssh"
#     user     = var.vsphere_linux_username
#     timeout  = "10m"
#     password = var.vsphere_linux_password
#     }       
#   }
#   provisioner "remote-exec" {
#     script = "./files/install_apache.sh"
#     connection {
#     host        = vsphere_virtual_machine.vm_01[count.index].default_ip_address
#     user        = var.vsphere_linux_username
#     type        = "ssh"
#     timeout     = "10m"
#     password    = var.vsphere_linux_password
#     script_path = "/root/install_apache.sh"
#     } 
#   }
# }

output "vsphere_private_ip" {
  value = vsphere_virtual_machine.vm.*.default_ip_address
}

