variable "vsphere_user" { 
  type        = string
}

variable "vsphere_admin_password" { 
  type        = string
}

variable "vsphere_server" {  
  type        = string
}

variable "virtual_machine_dns_servers" {
  type    = list(string)
  default = ["10.10.10.13", "10.10.10.9"]
}
variable "vsphere_compute_cluster" {
  description = "Computer Cluster or Host for the VM(s) being built"
  default = "AFSI-CLE"
  }

variable "vsphere_network" {
  description = "Network Name the VM(s) will be connected to"
  default = "VLAN 214 Development VDS"
  }

variable "vsphere_machine_template" {
  description = "template used for creating the vm(s)"
  default = "Templates CLE/Server 2019/cle_winsrv2019_dc_CORE_BASE"
  }

variable "vsphere_datastore" {
  description = "Datastore/Datastore cluster VM(s) will run on"
  default = "cle_templates"
}

variable "vsphere_vm_folder" {
  description = "vSphere VM Folder the VM(s) will be placed in"
  default = "Operations"
}

variable "vm_name_01" {
  description = "Name for the VM(s)"
  default = "cledwebdemo"
}

variable "vm_annotation" {
  description = "Annotation to add to the VM(s)"
  default = "Contact: Daniel Kelly \n Description: pTFE Demo  \n Ticket: SCREQXXXXXX \n Created By: built via Ansible/Terraform \n Created On: 8/10/2020"
}

variable "vsphere_datacenter" {
  description = "Datacenter where the VM(s) will be buillt"
  default = "Cleveland, OH"
}

variable "vm_count" {
  description = "Number of VMs to build"
  default = "1"
}