variable "vsphere_user" {}

variable "vsphere_admin_password" {
  type  = "string"
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