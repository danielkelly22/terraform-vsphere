# Vault Cluster Deployment Example

This is an example of how you would deploy a HA Vault cluster on AWS and VMWare. It's essentially the same approach using different providers.

I took a look at the [AWS Vault Module](https://registry.terraform.io/modules/hashicorp/vault/aws/latest) out in the public registery. It would be impossible to automatically
determine how a On-Prem VMWare deployment would be setup, so I rolled my own example. The details for each provider deployment may change depending on your specific environment.

## Architecture
The reference OSS architecture can be found [here](https://learn.hashicorp.com/tutorials/vault/reference-architecture?in=vault/day-one-consul#deployment-of-vault-in-three-availability-zones-oss).
There are 3 different types of servers being deployed:
- Vault Transit (1) - It's a small Vault server that is used to auto unseal the vault servers using the [Transit Engine](https://learn.hashicorp.com/tutorials/vault/autounseal-transit).
- Consul Storage (5) - Consul cluster that provides HA storage.
- Vault (3) - Vault cluster with the UI turned on.

## Before You Begin
- Make sure you have jq installed on your OSS or TFE Host machine.
- Have your ssh information.
- Copy the **terraform.tfvars.example** for either folder. Rename it **terraform.tfvars** and fill out the appropriate information.
- The Terraform version is set to the latest as of today 0.13.5. Make sure you have you binaries updated.

## Warning
I tried out the AWS version and it seems to work properly. The VMWare version has not been tested yet.