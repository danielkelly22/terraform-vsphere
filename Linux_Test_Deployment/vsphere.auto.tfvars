resource "tfe_variable" "vsphere_server" {
  key          = "vsphere_server"
  value        = "clepvcsa01.amtrustservices.com"
  category     = "terraform"
  workspace_id = "${tfe_workspace.test.id}"
  description  = "Cleveland Vsphere Server"
}

