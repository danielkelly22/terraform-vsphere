#!/bin/bash

###############################################################################################
#
#   Repo:           devops
#   File Name:      /scripts/consul.sh
#   Author:         Patrick Gryzan
#   Company:        Hashicorp
#   Date:           November 2020
#   Description:    Consul setup script for linux machines
#
###############################################################################################

set -e

#############################################################################################################################
#   Setup Environment
#############################################################################################################################
DATA_CENTER="dc1"
CONSUL_VERSION="1.8.5"
AGENT_TYPE="client"
RETRY_JOIN=""
SERVER_COUNT=1
SYSTEMD_TYPE="exec"
CONSUL_LICENSE=""
BIND_ADDRESS=''
RECURSORS="\"$(grep "nameserver" /etc/resolv.conf | cut -d' ' -f2)\""
ENCRYPT=""
UI="false"
CLIENT_ADDRESS="0.0.0.0"

HOME="/tmp"
BIN="/usr/local/bin"
CONFIG="/etc/consul.d"
PACKAGE="/opt/consul"

#   Grab Arguments
while getopts h:d:v:a:r:s:l:b:c:e:u:x: option
do
case "${option}"
in
h) HOME=${OPTARG};;
d) DATA_CENTER=${OPTARG};;
v) CONSUL_VERSION=${OPTARG};;
a) AGENT_TYPE=${OPTARG};;
r) RETRY_JOIN=${OPTARG};;
s) SERVER_COUNT=${OPTARG};;
l) CONSUL_LICENSE=${OPTARG};;
b) BIND_ADDRESS=${OPTARG};;
c) RECURSORS=${OPTARG};;
e) ENCRYPT=${OPTARG};;
u) UI=${OPTARG};;
x) CLIENT_ADDRESS=${OPTARG};;
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
        sudo yum install unzip iptables -y
        ;;
    *) echo -n "unknown operating system"; exit 1 ;;
esac

#   Set systemd type for the type of server. Clusters are set to notify.
if [ $SERVER_COUNT -gt 1 ] ; then
    SYSTEMD_TYPE="notify"
fi

#############################################################################################################################
#   Consul
#############################################################################################################################
echo "installing consul version ${CONSUL_VERSION}"

#   Download
curl --silent --remote-name https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip

#   Install
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul ${BIN}/
${BIN}/consul -autocomplete-install
complete -C ${BIN}/consul consul
sudo setcap cap_ipc_lock=+ep ${BIN}/consul
sudo rm consul_${CONSUL_VERSION}_linux_amd64.zip

#   Create User
sudo groupadd --system consul
sudo useradd  --shell /bin/false --system -g consul consul

#   Create Base Directories
sudo mkdir -p ${PACKAGE} ${CONFIG}
sudo chown -R consul:consul ${PACKAGE} ${CONFIG}
sudo chmod -R 775 ${PACKAGE} ${CONFIG}

if [ $AGENT_TYPE = "server" ] ; then
cat <<-EOF > /etc/systemd/system/consul.service
[Unit]
Description="Hashicorp Consul"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${CONFIG}/consul.hcl

[Service]
Type=${SYSTEMD_TYPE}
User=consul
Group=consul
ExecStart=${BIN}/consul agent -config-dir=${CONFIG}/
ExecReload=${BIN}/consul reload
ExecStop=${BIN}/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
else
cat <<-EOF > /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${CONFIG}/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=${BIN}/consul agent -config-dir=${CONFIG}/
ExecReload=${BIN}/consul reload
ExecStop=${BIN}/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
fi

cat <<-EOF > ${CONFIG}/consul.hcl
datacenter = "${DATA_CENTER}"
data_dir = "${PACKAGE}"
client_addr = "${CLIENT_ADDRESS}"
retry_interval = "5s"
retry_join = [ ${RETRY_JOIN} ]
bind_addr = "${BIND_ADDRESS}"
recursors = [ ${RECURSORS} ]
encrypt = "${ENCRYPT}"
connect {
    enabled = true
}
ports {
    grpc = 8502
}
EOF

if [ $AGENT_TYPE = "server" ] ; then
cat <<-EOF >> ${CONFIG}/consul.hcl
ui = ${UI}
server = true
bootstrap_expect = ${SERVER_COUNT}
EOF
fi

#   Enable the Service
echo "starting consul ${AGENT_TYPE}"
sudo systemctl enable consul
sudo service consul start

#############################################################################################################################
#   Setup Port Forwarding
#############################################################################################################################
echo "configuring resolved port forwarding and iptables"
sudo mkdir -p /etc/systemd/resolved.conf.d
cat <<-EOF > /etc/systemd/resolved.conf.d/consul.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF
sudo iptables -t nat -A OUTPUT -d localhost -p udp -m udp --dport 53 -j REDIRECT --to-ports 8600
sudo iptables -t nat -A OUTPUT -d localhost -p tcp -m tcp --dport 53 -j REDIRECT --to-ports 8600
sudo systemctl restart systemd-resolved

#############################################################################################################################
#   Add Consul License
#############################################################################################################################
if [[ $CONSUL_LICENSE != "" ]] ; then
    echo 'waiting for consul to startup'
    sleep 10
    consul license put "${CONSUL_LICENSE}"
fi

exit 0