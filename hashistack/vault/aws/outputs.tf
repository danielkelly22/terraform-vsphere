////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           hashistack
//  File Name:      /vault/aws/outputs.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           November 2020
//  Description:    This is an example of how to deploy a Vault cluster with a Consul data store
//                  The default configuration is a 3 (Vault) x 5 (Consul) cluster spread across 3 AWS availability zones.
//                  https://learn.hashicorp.com/tutorials/vault/reference-architecture?in=vault/day-one-consul#deployment-of-vault-in-three-availability-zones-oss
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

output "outputs" {
    value               = {
        storage_ssh             = local.storage_ssh
        transit_ssh             = "ssh -o stricthostkeychecking=no ${ var.image.username }@${ aws_instance.transit.public_ip } -y"
        transit_root_token      = data.external.transit.result.root_token
        transit_unseal_key      = data.external.transit.result.unseal_key
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