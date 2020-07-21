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
