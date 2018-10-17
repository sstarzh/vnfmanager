#!/bin/bash

# administratively disable a pool member using iControl REST
# BIG-IP mgmt port
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# remote BIG-IP address
host='192.168.1.1'

# tenant (partition) name
partition='Cloudify_01'

# path
path='TcpApplications'

# pool names
pool='tcp_pool'

# pool member addresses
serviceAddress='192.0.1.10'
servicePort='80'

# desired pool member state
state='user-down'

# request data
DATA='{"state":"'"$state"'"}'

response_code=$(curl -sku $user:$passwd -w "%{http_code}" -X PATCH -H "Content-Type: application/json" https://$host:$dfl_mgmt_port/mgmt/tm/ltm/pool/~$partition~$path~$pool/members/~$partition~$serviceAddress:$servicePort -d $DATA -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to update pool member; exiting with response code '"$response_code"'"
     exit 1
fi