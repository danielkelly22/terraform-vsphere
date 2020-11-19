#!/bin/bash

###############################################################################################
#
#   Repo:           devops
#   File Name:      /scripts/vault.sh
#   Author:         Patrick Gryzan
#   Company:        Hashicorp
#   Date:           November 2020
#   Description:    Vault setup script for linux machines
#                   Assume that the Consul client has been setup on the machine for storage.
#
###############################################################################################

set -e

#############################################################################################################################
#   Setup Environment
#############################################################################################################################
DATA_CENTER="dc1"
VAULT_VERSION="1.5.5"
CONSUL_ADDR="127.0.0.1:8500"
VAULT_LICENSE=""
TRANSIT_ADDR=""
AUTOUNSEAL=""

HOME="/tmp"
BIN="/usr/local/bin"
CONFIG="/etc/vault.d"
PACKAGE="/opt/vault"

#   Grab Arguments
while getopts h:d:v:c:l:t:a: option
do
case "${option}"
in
h) HOME=${OPTARG};;
d) DATA_CENTER=${OPTARG};;
v) VAULT_VERSION=${OPTARG};;
c) CONSUL_ADDR=${OPTARG};;
l) VAULT_LICENSE=${OPTARG};;
t) TRANSIT_ADDR=${OPTARG};;
a) AUTOUNSEAL=${OPTARG};;
esac
done

#   Move to Home Directory
cd ${HOME}

#   Get the OS Info
. /etc/os-release

#   Install unzip
case ${NAME,,} in
    'ubuntu') sudo apt-get install unzip -y ;;
    'centos linux') ;&
    'rhel') sudo yum install unzip -y ;;
    *) echo -n "unknown operating system"; exit 1 ;;
esac

#############################################################################################################################
#   Vault
#############################################################################################################################
echo "installing vault version ${VAULT_VERSION}"

#   Download
curl --silent --remote-name https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

#   Install
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo chown root:root vault
sudo mv vault ${BIN}/
${BIN}/vault -autocomplete-install
complete -C ${BIN}/vault vault
sudo setcap cap_ipc_lock=+ep ${BIN}/vault
sudo rm vault_${VAULT_VERSION}_linux_amd64.zip

#   Create User
sudo groupadd --system vault
sudo useradd  --shell /bin/false --system -g vault vault

#   Create Base Directories
sudo mkdir -p ${PACKAGE} ${CONFIG}
sudo chown -R vault:vault ${PACKAGE} ${CONFIG}
sudo chmod -R 775 ${PACKAGE} ${CONFIG}

# Write vault.hcl configuration
cat <<-EOF > ${CONFIG}/vault.hcl
storage "consul" {
    address = "${CONSUL_ADDR}"
    path    = "vault/"
}

listener "tcp" {
    address = "0.0.0.0:8200"
    tls_disable = true
}

seal "transit" {
    address = "http://${TRANSIT_ADDR}:8200"
    token = "${AUTOUNSEAL}"
    disable_renewal = "false"
    key_name = "autounseal"
    mount_path = "transit/"
    tls_skip_verify = "true"
}

disable_mlock = true
ui=true
EOF

# Write the Service Configuration
cat <<-EOF > /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${CONFIG}/vault.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=${BIN}/vault server -config=${CONFIG}/vault.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#   Enable the Service
echo "starting vault server"
sudo systemctl enable vault
sudo service vault start

# Export VAULT_ADDR to the bash environment
export VAULT_ADDR=http://127.0.0.1:8200/
sudo bash -c 'echo export VAULT_ADDR=http://127.0.0.1:8200/ >> /etc/profile'

# Sleep 30 seconds
echo 'waiting for vault to startup'
sleep 30

# Try to Initialize the Server
{
    # Initialize Vault Server
    echo 'Initialize Vault server'
    ${BIN}/vault operator init > ${PACKAGE}/init.log

    # Extract root token and unseal key from init.log
    token=$(sed -n 7p ${PACKAGE}/init.log | cut -d':' -f2 | cut -d' ' -f2)

    # Export VAULT_TOKEN to the bash environment
    export VAULT_TOKEN=$token
    sudo bash -c "echo 'export VAULT_TOKEN=${token}' >> /etc/profile"
} || true

if [[ $VAULT_LICENSE != "" ]] ; then
    echo 'writing vault license'
    ${BIN}/vault write /sys/license text="${VAULT_LICENSE}"
fi

exit 0