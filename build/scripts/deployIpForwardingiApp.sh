#!/bin/bash

# deploy a v1 iApp template using iControl REST
# BIG-IP mgmt port
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# remote BIG-IP address
host='192.168.1.1'

# friendly name for iApp deployment
deployment='ipforward'
traffic_group='/Common/traffic-group-1'

# GGSN/PSW-facing VLAN
vlan='/Common/internal'

# request data
DATA='{"name":"'"$deployment"'","partition":"Common","strictUpdates":"disabled","template":"/Common/f5.ip_forwarding","trafficGroup":"'"$traffic_group"'","lists":[{"name":"basic__vlan_selections","encrypted":"no","value":["'"$vlan"'"]}],"variables":[{"name":"basic__forward_all","encrypted":"no","value":"IPv4"},{"name":"basic__vlan_listening","encrypted":"no","value":"enabled"},{"name":"options__advanced","encrypted":"no","value":"no"},{"name":"options__display_help","encrypted":"no","value":"hide"}]}'

response_code=$(curl -sku $user:$passwd -w "%{http_code}" -X POST -H "Content-Type: application/json" https://$host:$dfl_mgmt_port/mgmt/tm/sys/application/service/ -d $DATA -o /dev/null)

if [[ $response_code != 200  ]]; then
     echo "Failed to install IP Forwarding iApp; exiting with response code '"$response_code"'"
     exit 1
fi