variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_datacenter" {}
variable "vsphere_vm_folder" {}
variable "vsphere_resource_pool" {}
variable "vsphere_datastore_cluster" {}
variable "vsphere_vm_network" {}
variable "vsphere_machine_template" {}
variable "vm_ipv4_addr" {}
variable "vm_ipv4_netmask" {}
variable "domain_name" {}
variable "vm_ipv4_gateway" {}

variable "vsphere_user_password" {
  type  = string
}

variable "centos_root_password" {
  type  = string
}

variable "centos_root_user" {
  type = string
  default = "root"
}

variable "virtual_machine_dns_servers" {
   type    = list(string)
}

variable "vm_name" {
  description = "Name for the VM(s)"
  default = "cledsensu"
}
variable "vm_name_2" {
  description = "Name for the VM(s)"
  default = "cledgraf"
}
variable "vm_name_3" {
  description = "Name for the VM(s)"
  default = "cledprom01"
}
variable "vm2_ipv4_addr" {
  description = "Name for the VM(s)"
  default = "10.10.225.175"
}
variable "vm2_ipv4_netmask" {
  description = "Name for the VM(s)"
  default = "24"
}
variable "vm3_ipv4_addr" {
  description = "Name for the VM(s)"
  default = "10.10.225.180"
}
variable "vm3_ipv4_netmask" {
  description = "Name for the VM(s)"
  default = "24"
}


variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Stephen Zuk, Eng Linux Support \n Description: Sensu Monitoring POC \n Ticket: N/A \n Created By: built via Terraform \n Created On: 10/07/2020"
}

variable "vm_count" {
  description = "Number of VMs to build"
  default = "1"
}
variable "vm2_count" {
  description = "Number of VMs to build"
  default = "1"
}
variable "vm3_count" {
  description = "Number of VMs to build"
  default = "1"
}
