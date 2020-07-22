variable "vsphere_user" {}
variable "vsphere_user" {}
variable "local_admin_user" {}
variable "local_admin_password" {}
variable "windows_admin_password" {}
variable "windows_admin_account" {}
variable "vsphere_datacenter" {}
variable "vsphere_web_vm_folder" {}
variable "vsphere_db_vm_folder" {}
variable "vsphere_app_vm_folder" {}
variable "vsphere_db_compute_cluster" {}
variable "vsphere_dev_db_compute_cluster" {}
variable "vsphere_compute_cluster" {}
variable "vsphere_datastore_cluster" {}
variable "vsphere_web_dev_network" {}
variable "vsphere_db_dev_network" {}
variable "vsphere_app_dev_network" {}
variable "vsphere_web_prod_network" {}
variable "vsphere_db_prod_network" {}
variable "vsphere_app_prod_network" {}
variable "vsphere_db_machine_template" {}
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

variable "virtual_machine_dns_server" {
   type    = list(string)
}

variable "vm_name_WEB" {
  description = "Name for the VM(s)"
  default = "LD9DWEBVIRS"
}

variable "vm_name_APP" {
  description = "Name for the VM(s)"
  default = "LD9DAAPPIRS"
}

variable "vm_name_DB" {
  description = "Name for the VM(s)"
  default = "LD9DEVDBSTG"
}

variable "vm_name_DB_rep" {
  description = "Name for the VM(s)"
  default = "LD9DEVDBREP"
}

variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Joseph Valdez \n Description: IRSx DEV Server \n Ticket: SCTASK0215776 \n Created By: built via Ansible/Terraform \n Created On: 07/28/2020"
}

variable "vm_count_dev_WEB" {
  description = "Number of VMs to build"
  default = "1"
}

variable "vm_count_dev_APP" {
  description = "Number of VMs to build"
  default = "1"
}

variable "vm_count_dev_DB" {
  description = "Number of VMs to build"
  default = "1"
}

variable "vm_count_dev_DB_rep" {
  description = "Number of VMs to build"
  default = "1"
}