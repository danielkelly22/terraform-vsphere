variable "vsphere_server" {}
variable "vsphere_user" {}
variable "vsphere_datacenter" {}
variable "vsphere_linux_vm_folder" {}
variable "vsphere_linux_compute_cluster" {}
variable "vsphere_linux_datastore_cluster" {}
variable "vsphere_ld9_dmz_web_app_network" {}
variable "vsphere_linux_machine_template" {}
variable "vm_app_dev_ip_address" {}
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

variable "vm_name_linux_test" {
  description = "Name for the VM(s)"
  default = "ld9pnc"
}

variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Stephen Zuk, Eng Linux Support \n Description: LD9 Nextcloud Instance \n Ticket: N/A \n Created By: built via Terraform \n Created On: 10/07/2020"
}

variable "vm_count_nextcloud" {
  description = "Number of VMs to build"
  default = "1"
}

