#!/bin/bash

###############################################################################################
#
#   Repo:           hashistack
#   File Name:      /vault/templates/vault.sh
#   Author:         Patrick Gryzan
#   Company:        Hashicorp
#   Date:           November 2020
#   Description:    Vault external data source bash script to retrieve initialization information
#
###############################################################################################

set -e

path=$(which jq)
if [[ -z "$path" ]] ; then
    path="./jq"
    if [[ ! -f "$path" ]] ; then
        curl https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > $path
        chmod 0755 $path
    fi
fi

eval "$(${path} -r '@sh "export EXECUTION_PATH=\(.execution_path) USERNAME=\(.username) VAULT_IPS=\(.vault_ips) PRIVATE_KEY=\(.private_key)"')"

cert="${EXECUTION_PATH}/vault_cert"
echo "${PRIVATE_KEY}" > $cert
chmod 400 $cert

ips=($VAULT_IPS)
output=""
for ip in "${ips[@]}"
do
    init=$(ssh -q -o stricthostkeychecking=no -o userknownhostsfile=/dev/null -i "${cert}" $USERNAME@$ip "if [[ -f \"/opt/vault/init.log\" ]]; then cat /opt/vault/init.log; fi")
    output="${output}${init}"
done

SAVEIFS=$IFS
IFS=$'\n'
data=($output)
IFS=$SAVEIFS

key_1=$(echo ${data[0]} | cut -d ':' -f2 | cut -d ' ' -f2)
key_2=$(echo ${data[1]} | cut -d ':' -f2 | cut -d ' ' -f2)
key_3=$(echo ${data[2]} | cut -d ':' -f2 | cut -d ' ' -f2)
key_4=$(echo ${data[3]} | cut -d ':' -f2 | cut -d ' ' -f2)
key_5=$(echo ${data[4]} | cut -d ':' -f2 | cut -d ' ' -f2)
root_token=$(echo ${data[5]} | cut -d ':' -f2 | cut -d ' ' -f2)
eval "${path} -n --arg root_token \"${root_token}\" --arg key_1 \"${key_1}\" --arg key_2 \"${key_2}\" --arg key_3 \"${key_3}\" --arg key_4 \"${key_4}\" --arg key_5 \"${key_5}\" '{\"root_token\":\"$root_token\",\"key_1\":\"$key_1\",\"key_2\":\"$key_2\",\"key_3\":\"$key_3\",\"key_4\":\"$key_4\",\"key_5\":\"$key_5\"}'"

exit 0