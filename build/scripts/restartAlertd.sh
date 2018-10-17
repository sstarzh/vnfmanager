#!/bin/bash

# restart alertd (SNMP) service using iControl REST
# must be done after uploading user_alert.conf
# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# set request data
DATA='{"command":"restart","name":"alertd"}'

# POST to BIG-IP
response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X POST 'https://$host:$dfl_mgmt_port/mgmt/tm/sys/service' -H "Origin: https://$host:$dfl_mgmt_port" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to restart the alertd service; exiting with response code '"$response_code"'"
     exit 1
fi