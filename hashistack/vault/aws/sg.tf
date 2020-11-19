////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Repo:           hashistack
//  File Name:      /vault/aws/sg.tf
//  Author:         Patrick Gryzan
//  Company:        Hashicorp
//  Date:           November 2020
//  Description:    This is an example of how to deploy a Vault cluster with a Consul data store
//                  The default configuration is a 3 (Vault) x 5 (Consul) cluster spread across 3 AWS availability zones.
//                  https://learn.hashicorp.com/tutorials/vault/reference-architecture?in=vault/day-one-consul#deployment-of-vault-in-three-availability-zones-oss
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Security Group
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
resource "aws_security_group" "sg" {
    name                        = "${var.info.name}-sg"

    //  SSH
    ingress {
        from_port               = 22
        to_port                 = 22
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  HTTP
    ingress {
        from_port               = 80
        to_port                 = 80
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  HTTPS
    ingress {
        from_port               = 443
        to_port                 = 443
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  Vault
    ingress {
        from_port               = 7300
        to_port                 = 7301
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        from_port               = 7301
        to_port                 = 7301
        protocol                = "udp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        from_port               = 8200
        to_port                 = 8201
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    //  Consul
    ingress {
        from_port               = 8300
        to_port                 = 8302
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        from_port               = 8301
        to_port                 = 8302
        protocol                = "udp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        from_port               = 8500
        to_port                 = 8500
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        from_port               = 8600
        to_port                 = 8600
        protocol                = "tcp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    ingress {
        from_port               = 8600
        to_port                 = 8600
        protocol                = "udp"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    egress {
        from_port               = 0
        to_port                 = 0
        protocol                = "-1"
        cidr_blocks             = ["0.0.0.0/0"]
    }

    tags                        = merge(map("Name", "${var.info.name}-sg", "role", "security group"), local.tags)
}