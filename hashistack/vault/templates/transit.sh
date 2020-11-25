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

sudo -i
echo "Testing" 1>&2
set -e

echo "Checking Path" 1>&2
path=$(which jq)
echo "path is $path" 1>&2
if [[ -z "$path" ]] ; then
   path="./jq"
   echo $path 1>&2
   if [[ ! -f "$path" ]] ; then
       echo "Attempting to curl" 1>&2
       curl https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 > $path 
       chmod 0755 $path 
   fi
fi

echo "1st Eval" 1>&2
eval "$(${path} -r '@sh "export EXECUTION_PATH=\(.execution_path) USERNAME=\(.username) PUBLIC_IP=\(.public_ip) PRIVATE_KEY=\(.private_key)"')" 1>&2

cert="${EXECUTION_PATH}/transit_cert"
echo "${PRIVATE_KEY}" > $cert
chmod 400 $cert

info=$(ssh -q -o stricthostkeychecking=no -o userknownhostsfile=/dev/null -i "${cert}" $USERNAME@$PUBLIC_IP "cat /opt/vault/creds")
root_token=$(echo ${info} | cut -d ' '  -f1)
unseal_key=$(echo ${info} | cut -d ' ' -f2)
autounseal_token=$(echo ${info} | cut -d ' ' -f3)
eval "${path} -n --arg root_token \"${root_token}\" --arg unseal_key \"${unseal_key}\" --arg autounseal_token \"${autounseal_token}\" '{\"root_token\":\"$root_token\",\"unseal_key\":\"$unseal_key\",\"autounseal_token\":\"$autounseal_token\"}'"
exit 0
