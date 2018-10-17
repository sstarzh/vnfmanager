#!/bin/bash

# revoke a license from BIG-IP using BIG-IQ (unmanaged pool, reachable device)
# remote BIG-IP address
bigip_host='192.168.1.1'
# remote BIG-IQ address
bigiq_host='192.168.1.2'
dfl_mgmt_port='443'
user='admin'
passwd='admin'
# license pool name
license_pool='cloudify'

DATA='{ "licensePoolName": "'"$license_pool"'", "command": "revoke", "address": "'"$bigip_host"'", "user": "'"$user"'", "password": "'"$passwd"'" }'

response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X POST 'https://$bigiq_host:$dfl_mgmt_port/mgmt/cm/device/tasks/licensing/pool/member-management' -H 'Content-Type: application/json' --data $DATA -o /dev/null)

if [[ $response_code != 202 ]]; then
     echo "Failed to begin license revocation; exiting with response code '"$response_code"'"
     exit 1
fi