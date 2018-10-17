#!/bin/bash

# install AS3 package using iControl REST
# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# set AS3 rpm file name
FN='f5-appsvcs-3.0.0-34.noarch.rpm'

# set request data
# packageFilePath can point anywhere local (e.g., the config_drive)
DATA='{"operation":"INSTALL","packageFilePath":"'"/var/config/rest/downloads/$FN"'"}'

# POST to BIG-IP
response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X POST 'https://$host:$dfl_mgmt_port/mgmt/shared/iapp/package-management-tasks' -H "Origin: https://$host:$dfl_mgmt_port" -H 'Content-Type: application/json;charset=UTF-8' --data $DATA -o /dev/null)

if [[ $response_code != 202  ]]; then
     echo "Failed to begin install of AS3 package; exiting with response code '"$response_code"'"
     exit 1
fi