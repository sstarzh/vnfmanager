#!/bin/bash

# enable CGNAT using iControl REST
# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# set request data
DATA='{"enabled":true}'

# POST to BIG-IP
response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X PATCH 'https://$host:$dfl_mgmt_port/mgmt/tm/sys/feature-module/cgnat' -H 'Content-Type: application/json;charset=UTF-8' --data $DATA -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to enable CGNAT; exiting with response code '"$response_code"'"
     exit 1
fi