variable "vsphere_server" {}
variable "vsphere_user" {}
variable "local_admin_user" {}
variable "local_admin_password" {}
variable "vsphere_datacenter" {}
variable "vsphere_linux_vm_folder" {}
variable "vsphere_compute_cluster" {}
variable "vsphere_datastore_cluster" {}
variable "vsphere_app_dev_network" {}
variable "vsphere_linux_machine_template" {}
variable "vsphere_machine_template" {}
variable "vm_web_dev_ip_address" {}
variable "vm_db_dev_ip_address" {}
variable "vm_app_dev_ip_address" {}
variable "vm_web_prod_ip_address" {}
variable "vm_db_prod_ip_address" {}
variable "vm_app_prod_ip_address" {}
variable "domain_name" {}

variable "vsphere_admin_password" {
  type  = string
}

variable "virtual_machine_dns_servers" {
   type    = list(string)
}

variable "vm_name_Linux_Test" {
  description = "Name for the VM(s)"
  default = "cledtftest"
}

variable "vm_annotation_1" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Stephen Zuk \n Description: Terraform Test Server \n Ticket: N/A \n Created By: built via Terraform \n Created On: 07/31/2020"
}

variable "vm_count_dev_Linux_Test" {
  description = "Number of VMs to build"
  default = "1"
}