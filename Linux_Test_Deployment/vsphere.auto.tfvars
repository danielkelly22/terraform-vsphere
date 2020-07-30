resource "tfe_variable" "vsphere_server" {
  key          = "vsphere_server"
  value        = "clepvcsa01.amtrustservices.com"
  category     = "terraform"
  description  = "Cleveland Vsphere Server"
}

