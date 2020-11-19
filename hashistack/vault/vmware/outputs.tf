////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           devops
//  File Name:      /vault/vmware/outputs.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           November 2020
//  Description:    This is an example of how to deploy a Vault cluster with a Consul data store
//                  The default configuartion is a 3 (Vault) x 5 (Consul) cluster spread across 3 AWS availability zones.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

output "outputs" {
    value               = {
        storage_ssh         = local.storage_ssh
        vault_ssh           = local.vault_ssh
        vault_http          = local.vault_http
        transit_ssh         = "ssh -o stricthostkeychecking=no ${ var.image.username }@${ vsphere_virtual_machine.transit.default_ip_address } -y"
        transit_root_token  = data.external.transit.result.root_token
        transit_unseal_key  = data.external.transit.result.unseal_key
    }
}