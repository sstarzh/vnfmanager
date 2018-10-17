#!/bin/bash

# configure SNMP using iControl REST
# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# set remote cloudify snmp manager address
remote_host='192.168.1.2'

# set request data
DATA='{"name":"cloudify","community":"public","host":"'"$remote_host"'"}'

# configure snmp trap destination
response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X POST 'https://$host:$dfl_mgmt_port/mgmt/tm/sys/snmp/traps/' -H 'Content-Type: application/json;charset=UTF-8' --data $DATA -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to configure snmp trap; exiting with response code '"$response_code"'"
     exit 1
fi

# set requiest data
DATA='{"allowedAddresses": ["'"$remote_host"'"]}'

# configure snmp allowed address
response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X PATCH 'https://$host:$dfl_mgmt_port/mgmt/tm/sys/snmp/' -H 'Content-Type: application/json;charset=UTF-8' --data $DATA -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to configure snmp allowed address; exiting with response code '"$response_code"'"
     exit 1
fi