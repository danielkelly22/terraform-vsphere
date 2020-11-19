#!/bin/bash

###############################################################################################
#
#   Repo:           devops
#   File Name:      /scripts/transit.sh
#   Author:         Patrick Gryzan
#   Company:        Hashicorp
#   Date:           November 2020
#   Description:    Vault setup script for linux machines
#
###############################################################################################

set -e

#############################################################################################################################
#   Setup Environment
#############################################################################################################################
DATA_CENTER="dc1"
VAULT_VERSION="1.5.5"
VAULT_LICENSE=""
IP="0.0.0.0"

HOME="/tmp"
BIN="/usr/local/bin"
CONFIG="/etc/vault.d"
PACKAGE="/opt/vault"

#   Grab Arguments
while getopts h:d:v:l:i: option
do
case "${option}"
in
h) HOME=${OPTARG};;
d) DATA_CENTER=${OPTARG};;
v) VAULT_VERSION=${OPTARG};;
l) VAULT_LICENSE=${OPTARG};;
i) IP=${OPTARG};;
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
    'rhel')
        sudo setenforce 0
        sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
        sudo yum install unzip -y ;;
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
storage "file" {
    path = "${PACKAGE}/data"
}

listener "tcp" {
    address = "${IP}:8200"
    tls_disable = true
}

disable_mlock = true
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
Type=exec
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

# Sleep 30 seconds
echo 'waiting for vault to startup'
sleep 30

# Export VAULT_ADDR to the bash environment
echo 'exporting vault address'
export VAULT_ADDR=http://${IP}:8200/
sudo bash -c "echo 'export VAULT_ADDR=http://${IP}:8200/' >> /etc/profile"

# Initialize Vault server
echo 'initializing vault'
${BIN}/vault operator init -key-shares=1 -key-threshold=1 > ${PACKAGE}/init.log

# Extract root token and unseal key from init.log
token=$(sed -n 3p ${PACKAGE}/init.log | cut -d':' -f2 | cut -d' ' -f2)
unseal_key=$(sed -n 1p ${PACKAGE}/init.log | cut -d':' -f2 | cut -d' ' -f2)

# Create creds file
touch ${PACKAGE}/creds

# Write root token to /root/token
echo $token >> ${PACKAGE}/creds

# Write unseal key to /root/unseal_key
echo $unseal_key >> ${PACKAGE}/creds

# Export VAULT_TOKEN to the bash environment
echo 'exporting vault token'
export VAULT_TOKEN=$token
sudo bash -c "echo 'export VAULT_TOKEN=${token}' >> /etc/profile"

# Unseal Vault server
${BIN}/vault operator unseal $unseal_key

if [[ $VAULT_LICENSE != "" ]] ; then
    echo 'writing license'
    ${BIN}/vault write /sys/license text="${VAULT_LICENSE}"
fi

# Enable the audit log
echo 'enabling the audit log'
${BIN}/vault audit enable file file_path=${PACKAGE}/audit.log

# Enable the Transit Engine
echo 'enabling the transit engine'
${BIN}/vault secrets enable transit

# Create the encryption key
echo 'creating the encryption key'
${BIN}/vault write -f transit/keys/autounseal

# create autounseal policy
echo 'creating the autounseal policy'
cat <<-EOF > ${PACKAGE}/autounseal.hcl
path "transit/encrypt/autounseal" {
   capabilities = [ "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "update" ]
}
EOF

${BIN}/vault policy write autounseal ${PACKAGE}/autounseal.hcl

# create wrapped client token
echo 'creating the wrapped autounseal client token'
${BIN}/vault token create -policy="autounseal" -wrap-ttl=120  > ${PACKAGE}/wrapper.log
token=$(sed -n 3p ${PACKAGE}/wrapper.log | cut -d':' -f2 | cut -d' ' -f19)
VAULT_TOKEN="${token}" ${BIN}/vault unwrap > ${PACKAGE}/autounseal.log
token=$(sed -n 3p ${PACKAGE}/autounseal.log | cut -d' ' -f17)
echo $token >> ${PACKAGE}/creds

exit 0