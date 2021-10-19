###
# TODO: Anti-affinity rules
# https://registry.terraform.io/providers/hashicorp/vsphere/latest/docs/resources/compute_cluster_vm_anti_affinity_rule
#
variable "vm_name_prefix" {
  type=string
  default="clepk8s02"
}
variable "vsphere_template_name" {
  type=string
  default="ubuntu-2004-base-2021-07-20T133157"
}
variable "number_of_nodes" {
  type=string
  default=1
}

###
variable "vsphere_user" {}
variable "vsphere_server" {
  type=string
  default="clepvcsa01.amtrustservices.com"
}

variable "vsphere_datacenter_name" {
  type=string
  default="Cleveland, OH"
}

variable "vsphere_vm_folder_name" {
  type=string
  default="kubernetes"
}

variable "vsphere_compute_cluster_name" {
  type=string
  default="Linux-CLE"
}

variable "vsphere_datastore_cluster_name" {
  type=string
  default="cle_lin_cluster"
}

variable "vsphere_network_name" {
  type=string
  default="VLAN 600 Prod VDS"
}

# TODO
variable "vm_netplan_gateway" {
  type=string
  default="10.88.0.1"
}

variable "vm_netplan_nameservers" {
  type=list(string)
  default=["10.10.10.9", "10.10.10.10"]
}

# TODO
variable "vm_netplan_ip_address_list" {
  type=list(string)
  default=[
    "10.88.0.23",
  ]
}

//variable "vm_app_dev_ip_address" {}
//variable "domain_name" {}

###

variable alphabet_list {
  type = list(string)
  default = [
    "a",
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