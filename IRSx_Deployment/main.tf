terraform {
  required_version = ">= 0.12"
  backend "remote" {
    hostname     = "tfe.amtrustgroup.com"
    organization = "AmTrust-vSphere"

    workspaces {
      name = "IRSx_Deployment"
    }
  }
}

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_admin_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_datastore_cluster" "datastore_cluster" {
  name          = var.vsphere_datastore_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data  "vsphere_compute_cluster" "db_cluster" {
  name            = "${var.vsphere_db_compute_cluster}"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}" 
}

data  "vsphere_compute_cluster" "dev_db_cluster" {
  name            = "${var.vsphere_dev_db_compute_cluster}"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}" 
}

data  "vsphere_compute_cluster" "compute_cluster" {
  name            = "${var.vsphere_compute_cluster}"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}" 
}

data "vsphere_network" "web_dev_network" {
  name          = "${var.vsphere_web_dev_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "db_dev_network" {
  name          = "${var.vsphere_db_dev_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "app_dev_network" {
  name          = "${var.vsphere_app_dev_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "web_prod_network" {
  name          = "${var.vsphere_web_prod_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "db_prod_network" {
  name          = "${var.vsphere_db_prod_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "app_prod_network" {
  name          = "${var.vsphere_app_prod_network}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name             = "${var.vsphere_machine_template}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
}
