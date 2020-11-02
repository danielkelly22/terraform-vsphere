variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_datacenter" {}
variable "vsphere_vm_folder" {}
variable "vsphere_compute_cluster" {}
variable "vsphere_datastore_cluster" {}
variable "vsphere_network" {}
variable "vsphere_machine_template" {}
variable "domain_name" {}

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
  default = "ld9uuniverse02"
}

variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Jason Fuller, Eng Linux Support \n Description: LD9 Nextcloud Instance \n Ticket: N/A \n Created By: built via Terraform \n Created On: 10/07/2020"
}

variable "vm_count" {
  description = "Number of VMs to build"
  default = "1"
}

