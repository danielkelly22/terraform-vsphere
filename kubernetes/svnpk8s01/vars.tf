###
variable "vm_name_prefix" {
  type=string
  default="svnpk8s01"
}
variable "vsphere_template_name" {
  type=string
  default="svn-ubuntu-2004-base-2021-07-20T133157"
}
variable "number_of_nodes" {
  type=string
  default=5
}

###
variable "vsphere_user" {}
variable "vsphere_server" {
  type=string
  default="clepvcsa01.amtrustservices.com"
}

variable "vsphere_datacenter_name" {
  type=string
  default="Seven Hills, OH"
}

variable "vsphere_vm_folder_name" {
  type=string
  default="kubernetes"
}

variable "vsphere_compute_cluster_name" {
  type=string
  default="AFSI-SVN"
}

variable "vsphere_datastore_cluster_name" {
  type=string
  default="svn_afsi_01"
}

variable "vsphere_network_name" {
  type=string
  default="VLAN 50 Production VDS"
}

variable "vm_netplan_gateway" {
  type=string
  default="10.58.50.1"
}

variable "vm_netplan_nameservers" {
  type=list(string)
  default=["10.59.10.21", "10.59.10.22"]
}

variable "vm_netplan_ip_address_list" {
  type=list(string)
  default=[
    "10.58.50.73",
    "10.58.50.74",
    "10.58.50.75",
    "10.58.50.76",
    "10.58.50.77",
  ]
}

//variable "vm_app_dev_ip_address" {}
//variable "domain_name" {}

###

variable alphabet_list {
  type = list(string)
  default = [
    "a",
    "b",
    "c",
    "d",
    "e"
  ]
}

variable "vsphere_user_password" {type  = string}
//variable "vm_root_password"      {type  = string}
//variable "vm_root_user"          {type = string, default = "ubuntu"}
//variable "virtual_machine_dns_servers" {
//   type    = list(string)
//}

//variable "vm_name_linux_test" {
//  description = "Name for the VM(s)"
//  default = "clednixtftest"
//}

//variable "vm_annotation_1" {
//  description = "Annotation to add to the VM(s)"
//  default =  "Contact: Stephen Zuk \n Description: Terraform Test Server \n Ticket: N/A \n Created By: built via Terraform \n Created On: 07/31/2020"
//}

//variable "vm_count_dev_linux_test" {
//  description = "Number of VMs to build"
//  default = "1"
//}
