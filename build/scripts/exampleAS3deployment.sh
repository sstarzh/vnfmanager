#!/bin/bash

# deploy service configuration using provided example AS3 declaration
# this example deploys tcp/udp host virtuals using the self IP address and a wildcard virtual for all other protocols
# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# set virtual server addresses
virtualAddress='192.168.120.8'
# to modify pool members, update entries in members array and POST declaration
pool_members_tcp='{"enable":true,"servicePort":80,"serverAddresses":["192.0.5.10"]},{"enable":true,"servicePort":80,"serverAddresses":["192.0.5.11"]}'
pool_members_udp='{"enable":true,"servicePort":53,"serverAddresses":["192.0.5.10"]},{"enable":true,"servicePort":53,"serverAddresses":["192.0.5.11"]}'

# set request data (declaration)
# pool.member.enable will be replaced with admin down option
DATA='{"class":"AS3","action":"deploy","persist":true,"declaration":{"class":"ADC","schemaVersion":"3.0.0","id":"cfy_01","label":"Sample01","remark":"myRemark","Cloudify_01":{"class":"Tenant","TcpApplications":{"class":"Application","template":"tcp","serviceMain":{"class":"Service_TCP","profileTCP":{"use":"tcp_profile"},"virtualAddresses":["'"$virtualAddress"'"],"virtualPort":0,"pool":"tcp_pool"},"tcp_pool":{"class":"Pool","monitors":[{"use":"tcp_monitor"}],"members":['"$pool_members_tcp"']},"tcp_profile":{"class":"TCP_Profile"},"tcp_monitor":{"class":"Monitor","monitorType":"tcp","send":"","receive":"","adaptive":false}},"UdpApplications":{"class":"Application","template":"udp","serviceMain":{"class":"Service_UDP","profileUDP":{"use":"udp_profile"},"virtualAddresses":["'"$virtualAddress"'"],"virtualPort":0,"pool":"udp_pool"},"udp_pool":{"class":"Pool","monitors":[{"use":"udp_monitor"}],"members":['"$pool_members_udp"']},"udp_profile":{"class":"UDP_Profile"},"udp_monitor":{"class":"Monitor","monitorType":"udp","send":"","receive":"","adaptive":false}},"FastL4Applications":{"class":"Application","template":"l4","serviceMain":{"class":"Service_L4","translateServerAddress":false,"translateServerPort":false,"profileL4":{"use":"L4_Profile"},"virtualAddresses":["0.0.0.0"],"virtualPort":0},"L4_Profile":{"class":"L4_Profile","looseClose":true,"looseInitialization":true,"resetOnTimeout":false}}}}}'

# POST to BIG-IP
response_code=$(curl -kvu $user:$passwd -w "%{http_code}" -X POST 'https://$host:$dfl_mgmt_port/mgmt/shared/appsvcs/declare' -H 'Content-Type: application/json' -H 'Expect:' --data $DATA -o /dev/null)

if [[ $response_code != 200 ]]; then
     echo "Failed to deploy service configuration; exiting with response code '"$response_code"'"
     exit 1
fi