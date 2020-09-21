variable "vsphere_server" {}
variable "vsphere_user" {}
variable "local_admin_user" {}
variable "local_admin_password" {}
variable "windows_admin_password" {}
variable "windows_admin_account" {}
variable "vsphere_datacenter" {}
variable "vsphere_SSAS_vm_folder" {}
variable "vsphere_SSIS_vm_folder" {}
variable "vsphere_compute_cluster" {}
variable "vsphere_datastore_cluster" {}
variable "vsphere_SSAS_dev_network" {}
variable "vsphere_SSIS_dev_network" {}
variable "vsphere_db_machine_template" {}
variable "vm_SSAS_dev_ip_address" {}
variable "vm_SSIS_dev_ip_address" {}
variable "domain_name" {}

variable "vsphere_admin_password" {
  type  = string
}

variable "virtual_machine_dns_servers" {
   type    = list(string)
}

variable "vm_name_SSAS" {
  description = "Name for the VM(s)"
  default = "LD9DEVCCPSSAS01"
}

variable "vm_name_SSIS" {
  description = "Name for the VM(s)"
  default = "LD9DEVCCPSSIS"
}

variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Joseph Valdez \n Description: CCP DEV Server \n Ticket: REQ0202165 \n Created By: built via Ansible/Terraform \n Created On: 09/22/2020"
}

variable "vm_count_dev_SSAS" {
  description = "Number of VMs to build"
  default = "1"
}

variable "vm_count_dev_SSIS" {
  description = "Number of VMs to build"
  default = "1"
}