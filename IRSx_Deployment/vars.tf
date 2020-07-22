variable "vsphere_machine_template" {
  description = "template used for creating the vm(s)"
  default = "Templates LD9/Server 2019/ld9_winsrv2019_dc_CLEANBASE"
}

variable "vm_name_WEB" {
  description = "Name for the VM(s)"
  default = "LD9QAWEBVSC"
}

variable "vm_name_APP" {
  description = "Name for the VM(s)"
  default = "LD9QAAPPVSC"
}

variable "vm_ip_address" {
  description = "IP Address of the VM(s)"
  default = "10.95.8"
}

variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default =  "Contact: Joseph Valdez \n Description: VSC QA  \n Ticket: SCTASK0215776 \n Created By: built via Ansible/Terraform \n Created On: 5/14/2020"
}

variable "vm_count_WEB" {
  description = "Number of VMs to build"
  default = "1"
}

variable "vm_count_APP" {
  description = "Number of VMs to build"
  default = "1"
}

variable "vm_count_DB" {
  description = "Number of VMs to build"
  default = "1"
}