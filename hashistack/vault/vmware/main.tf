////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Environment
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
terraform {
    required_version            = ">= 0.13.5"
}

provider "vsphere" {
    user                        = var.vsphere.user
    password                    = var.vsphere.password
    vsphere_server              = var.vsphere.server

    # If you have a self-signed cert
    allow_unverified_ssl        = true
}

locals {
    storage_servers_private     = [
        for key in keys(var.storage_zones):
        vsphere_virtual_machine.storage[key].default_ip_address
    ]
    storage_ssh                 = [
        for ip in local.storage_servers_private:
        "ssh -o stricthostkeychecking=no ${ var.image.username }@${ ip } -y"
    ]
    storage_retry_join          = "\"${join("\", \"", local.storage_servers_private)}\""
    vault_servers_private       = [
        for key in keys(var.vault_zones):
        vsphere_virtual_machine.vault[key].default_ip_address
    ]
    vault_ssh                   = [
        for ip in local.vault_servers_private:
        "ssh -o stricthostkeychecking=no ${ var.image.username }@${ ip } -y"
    ]
    vault_http                  = [
        for ip in local.vault_servers_private:
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
        username                = var.image.username
        public_ip               = vsphere_virtual_machine.transit.default_ip_address
        private_key             = var.ssh.private_key
    }
}

data "vsphere_datacenter" "dc" {
    name                        = var.vsphere.datacenter
}

data "vsphere_datastore" "datastore" {
    name                        = var.vsphere.datastore
    datacenter_id               = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
    name                        = var.vsphere.cluster
    datacenter_id               = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
    name                        = var.vsphere.network
    datacenter_id               = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
    name                        = var.image.name
    datacenter_id               = data.vsphere_datacenter.dc.id
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Virtual Machines
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "vsphere_virtual_machine" "transit" {
    name                        = "${var.info.name}vaulttrn01"
    resource_pool_id            = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id                = data.vsphere_datastore.datastore.id
    guest_id                    = data.vsphere_virtual_machine.template.guest_id
    scsi_type                   = data.vsphere_virtual_machine.template.scsi_type

    num_cpus                    = var.transit.cpus
    memory                      = var.transit.memory

    network_interface {
        network_id              = data.vsphere_network.network.id
        adapter_type            = data.vsphere_virtual_machine.template.network_interface_types[0]
    }

    disk {
        label                   = "disk0"
        size                    = data.vsphere_virtual_machine.template.disks.0.size
        eagerly_scrub           = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
        thin_provisioned        = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    }

    clone {
        template_uuid           = data.vsphere_virtual_machine.template.id

        customize {
            linux_options {
                host_name       = "${var.info.name}-transit"
                domain          = var.vsphere.domain
            }

            network_interface {
                ipv4_address    = var.transit.ip
                ipv4_netmask    = var.server.mask
            }

            ipv4_gateway        = var.server.gateway
        }
    }
}

resource "vsphere_virtual_machine" "storage" {
    for_each                    = var.storage_zones
    name                        = "${var.info.name}vaultsto${each.key}"
    resource_pool_id            = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id                = data.vsphere_datastore.datastore.id
    guest_id                    = data.vsphere_virtual_machine.template.guest_id
    scsi_type                   = data.vsphere_virtual_machine.template.scsi_type

    num_cpus                    = var.server.cpus
    memory                      = var.server.memory

    network_interface {
        network_id              = data.vsphere_network.network.id
        adapter_type            = data.vsphere_virtual_machine.template.network_interface_types[0]
    }

    disk {
        label                   = "disk0"
        size                    = data.vsphere_virtual_machine.template.disks.0.size
        eagerly_scrub           = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
        thin_provisioned        = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    }

    clone {
        template_uuid           = data.vsphere_virtual_machine.template.id

        customize {
            linux_options {
                host_name       = "${var.info.name}-storage-${each.key}"
                domain          = var.vsphere.domain
            }

            network_interface {
                ipv4_address    = each.value
                ipv4_netmask    = var.server.mask
            }

            ipv4_gateway        = var.server.gateway
        }
    }
}

resource "null_resource" "install_storage" {
    for_each                    = vsphere_virtual_machine.storage

    connection {
        type                    = "ssh"
        host                    = vsphere_virtual_machine.storage[each.key].default_ip_address
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

resource "vsphere_virtual_machine" "vault" {
    for_each                    = var.vault_zones
    name                        = "${var.info.name}vault${each.key}"
    resource_pool_id            = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id                = data.vsphere_datastore.datastore.id
    guest_id                    = data.vsphere_virtual_machine.template.guest_id
    scsi_type                   = data.vsphere_virtual_machine.template.scsi_type

    num_cpus                    = var.server.cpus
    memory                      = var.server.memory

    network_interface {
        network_id              = data.vsphere_network.network.id
        adapter_type            = data.vsphere_virtual_machine.template.network_interface_types[0]
    }

    disk {
        label                   = "disk0"
        size                    = data.vsphere_virtual_machine.template.disks.0.size
        eagerly_scrub           = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
        thin_provisioned        = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    }

    clone {
        template_uuid           = data.vsphere_virtual_machine.template.id

        customize {
            linux_options {
                host_name       = "${var.info.name}-vault-${each.key}"
                domain          = var.vsphere.domain
            }

            network_interface {
                ipv4_address    = each.value
                ipv4_netmask    = var.server.mask
            }

            ipv4_gateway        = var.server.gateway
        }
    }
}

resource "null_resource" "install_vault" {
    for_each                    = vsphere_virtual_machine.vault

    connection {
        type                    = "ssh"
        host                    = vsphere_virtual_machine.vault[each.key].default_ip_address
        user                    = var.image.username
        private_key             = var.ssh.private_key
    }

    provisioner "remote-exec" {
        inline                  = [
            "sudo chmod +x /tmp/consul.sh",
            "sudo /tmp/consul.sh -d '${var.info.data_center}' -v '${var.info.consul_version}' -e '${var.info.consul_encrypt}' -b '{{ GetInterfaceIP \\\"eth0\\\" }}' -r '${local.storage_retry_join}' -x '127.0.0.1'",
            "sudo chmod +x /tmp/vault.sh",
            "sudo /tmp/vault.sh -d '${var.info.data_center}' -v '${var.info.vault_version}' -t '${vsphere_virtual_machine.transit.default_ip_address}' -a '${data.external.transit.result.autounseal_token}'",
            "sudo rm -r /tmp/*.sh",
        ]
    }

    depends_on                  = [vsphere_virtual_machine.transit, vsphere_virtual_machine.vault, null_resource.install_storage]
}