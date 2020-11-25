#!/bin/bash

###############################################################################################
#
#   Repo:           hashistack
#   File Name:      /vault/templates/transit.sh
#   Author:         Patrick Gryzan
#   Company:        Hashicorp
#   Date:           November 2020
#   Description:    Vault external data source bash script to retrieve initialization information
#
###############################################################################################

set -e 

#path=$(which jq)
#if [[ -z "$path" ]] ; then
 #   path="./jq" 
 #   if [[ ! -f "$path" ]] ; then
 #       curl https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > $path 
 #       chmod 0755 $path 
#    fi
#fi

#eval "$(${path} -r '@sh "export EXECUTION_PATH=\(.execution_path) USERNAME=\(.username) PUBLIC_IP=\(.public_ip) PRIVATE_KEY=\(.private_key)"')" > /tmp/tf_output/output.txt 2>&1

#cert="${EXECUTION_PATH}/transit_cert" > /tmp/output.txt 2>&1
#echo "${PRIVATE_KEY}" > $cert > /tmp/output.txt 2>&1
#chmod 400 $cert > /tmp/output.txt 2>&1

#info=$(ssh -q -o stricthostkeychecking=no -o userknownhostsfile=/dev/null -i "${cert}" $USERNAME@$PUBLIC_IP "cat /opt/vault/creds") > /tmp/tf_output/output.txt 2>&1
#root_token=$(echo ${info} | cut -d ' '  -f1)
#unseal_key=$(echo ${info} | cut -d ' ' -f2)
#autounseal_token=$(echo ${info} | cut -d ' ' -f3)
#eval "${path} -n --arg root_token \"${root_token}\" --arg unseal_key \"${unseal_key}\" --arg autounseal_token \"${autounseal_token}\" '{\"root_token\":\"$root_token\",\"unseal_key\":\"$unseal_key\",\"autounseal_token\":\"$autounseal_token\"}'" > /tmp/tf_output/output.txt 2>&1
#exit 0
