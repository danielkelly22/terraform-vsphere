////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           hashistack
//  File Name:      /vault/aws/main.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           November 2020
//  Description:    This is an example of how to deploy a Vault cluster with a Consul data store
//                  The default configuration is a 3 (Vault) x 5 (Consul) cluster spread across 3 AWS availability zones.
//                  https://learn.hashicorp.com/tutorials/vault/reference-architecture?in=vault/day-one-consul#deployment-of-vault-in-three-availability-zones-oss
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Environment
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
terraform {
    required_version            = ">= 0.13.5"
}

provider "aws" {
    access_key                  = var.aws.access_key
    secret_key                  = var.aws.secret_key
    region                      = var.aws.region
}

locals {
    storage_servers_private     = length(aws_instance.storage) == 0 ? [] : [
        for key in keys(var.storage_zones):
        aws_instance.storage[key].private_ip
    ]
    storage_servers_public      = length(aws_instance.storage) == 0 ? [] : [
        for key in keys(var.storage_zones):
        aws_instance.storage[key].public_ip
    ]
    storage_ssh                 = length(aws_instance.storage) == 0 ? [] : [
        for ip in local.storage_servers_public:
        "ssh -o stricthostkeychecking=no ${ var.image.username }@${ ip } -y"
    ]
    storage_retry_join          = "\"${join("\", \"", local.storage_servers_private)}\""
    vault_servers_private       = length(aws_instance.vault) == 0 ? [] : [
        for key in keys(var.vault_zones):
        aws_instance.vault[key].private_ip
    ]
    vault_servers_public        = length(aws_instance.vault) == 0 ? [] : [
        for key in keys(var.vault_zones):
        aws_instance.vault[key].public_ip
    ]
    vault_ssh                   = length(aws_instance.vault) == 0 ? [] : [
        for ip in local.vault_servers_public:
        "ssh -o stricthostkeychecking=no ${ var.image.username }@${ ip } -y"
    ]
    vault_http                  = length(aws_instance.vault) == 0 ? [] : [
        for ip in local.vault_servers_public:
        "http://${ ip }:8200"
    ]
    tags                        = {
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
data "external" "transit" {
    program                     = ["bash", "${path.module}/../templates/transit.sh"]
    query                       = {
        execution_path          = path.module
        username                = var.image.username
        public_ip               = aws_instance.transit.public_ip
        private_key             = var.ssh.private_key
    }
    depends_on                  = [aws_instance.transit]
}

data "external" "vault" {
    program                     = ["bash", "${path.module}/../templates/vault.sh"]
    query                       = {
        execution_path          = path.module
        username                = var.image.username
        vault_ips               = join(" ", local.vault_servers_public)
        private_key             = var.ssh.private_key
    }
    depends_on                  = [null_resource.install_vault]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Virtual Machines
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_instance" "transit" {
    availability_zone           = var.transit.zone
    ami                         = var.image.name
    instance_type               = var.transit.type
    key_name                    = var.ssh.key_name
    vpc_security_group_ids      = [aws_security_group.sg.id]
    ebs_optimized               = true
    tags                        = merge(map("Name", "${var.info.name}-transit", "role", "vault transit server"), local.tags)

    root_block_device {
        delete_on_termination   = true
        volume_size             = var.transit.volume_size
        volume_type             = "gp2"
    }

    connection {
        type                    = "ssh"
        host                    = self.public_ip
        user                    = var.image.username
        private_key             = var.ssh.private_key
    }

    provisioner "file" {
        source                  = "../../scripts/transit.sh"
        destination             = "/tmp/transit.sh"
    }

    provisioner "remote-exec" {
        inline                  = [
            "sudo chmod +x /tmp/transit.sh",
            "sudo /tmp/transit.sh -d '${var.info.data_center}' -v '${var.info.vault_version}' -i '${aws_instance.transit.private_ip}'",
            "sudo rm -r /tmp/transit.sh",
        ]
    }
}

resource "aws_instance" "storage" {
    for_each                    = var.storage_zones
    availability_zone           = each.value
    ami                         = var.image.name
    instance_type               = var.server.type
    key_name                    = var.ssh.key_name
    vpc_security_group_ids      = [aws_security_group.sg.id]
    ebs_optimized               = true
    tags                        = merge(map("Name", "${var.info.name}-storage-${each.key}", "role", "consul storage server"), local.tags)

    root_block_device {
        delete_on_termination   = true
        volume_size             = var.server.volume_size
        volume_type             = "gp2"
    }

    connection {
        type                    = "ssh"
        host                    = self.public_ip
        user                    = var.image.username
        private_key             = var.ssh.private_key
    }

    provisioner "file" {
        source                  = "../../scripts/consul.sh"
        destination             = "/tmp/consul.sh"
    }
}

resource "null_resource" "install_storage" {
    for_each                    = aws_instance.storage

    connection {
        type                    = "ssh"
        host                    = aws_instance.storage[each.key].public_ip
        user                    = var.image.username
        private_key             = var.ssh.private_key
    }

    provisioner "remote-exec" {
        inline                  = [
            "sudo chmod +x /tmp/consul.sh",
            "sudo /tmp/consul.sh -a 'server' -d '${var.info.data_center}' -v '${var.info.consul_version}' -l '${var.info.consul_license}' -e '${var.info.consul_encrypt}' -b '{{ GetInterfaceIP \\\"eth0\\\" }}' -s ${length(var.storage_zones)} -r '${local.storage_retry_join}'",
            "sudo rm -r /tmp/consul.sh",
        ]
    }
}

resource "aws_instance" "vault" {
    for_each                    = var.vault_zones
    availability_zone           = each.value
    ami                         = var.image.name
    instance_type               = var.server.type
    key_name                    = var.ssh.key_name
    vpc_security_group_ids      = [aws_security_group.sg.id]
    ebs_optimized               = true
    tags                        = merge(map("Name", "${var.info.name}-vault-${each.key}", "role", "vault server"), local.tags)

    root_block_device {
        delete_on_termination   = true
        volume_size             = var.server.volume_size
        volume_type             = "gp2"
    }

    connection {
        type                    = "ssh"
        host                    = self.public_ip
        user                    = var.image.username
        private_key             = var.ssh.private_key
    }

    provisioner "file" {
        source                  = "../../scripts/"
        destination             = "/tmp"
    }
}

resource "null_resource" "install_vault" {
    for_each                    = aws_instance.vault

    connection {
        type                    = "ssh"
        host                    = aws_instance.vault[each.key].public_ip
        user                    = var.image.username
        private_key             = var.ssh.private_key
    }

    provisioner "remote-exec" {
        inline                  = [
            "sudo chmod +x /tmp/consul.sh",
            "sudo /tmp/consul.sh -d '${var.info.data_center}' -v '${var.info.consul_version}' -e '${var.info.consul_encrypt}' -b '{{ GetInterfaceIP \\\"eth0\\\" }}' -r '${local.storage_retry_join}' -x '127.0.0.1'",
            "sudo chmod +x /tmp/vault.sh",
            "sudo /tmp/vault.sh -d '${var.info.data_center}' -v '${var.info.vault_version}' -t '${aws_instance.transit.private_ip}' -a '${data.external.transit.result.autounseal_token}'",
            "sudo rm -r /tmp/*.sh",
        ]
    }

    depends_on                  = [aws_instance.transit, aws_instance.vault, null_resource.install_storage]
}