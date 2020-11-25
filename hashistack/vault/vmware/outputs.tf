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
        vault_http              = local.vault_http
        vault_recovery_key_1    = data.external.vault.result.key_1
        vault_recovery_key_2    = data.external.vault.result.key_2
        vault_recovery_key_3    = data.external.vault.result.key_3
        vault_recovery_key_4    = data.external.vault.result.key_4
        vault_recovery_key_5    = data.external.vault.result.key_5
        vault_root_token        = data.external.vault.result.root_token
        vault_ssh               = local.vault_ssh
    }
}
