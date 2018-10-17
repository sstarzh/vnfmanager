#!/bin/bash

# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# fetch all performance stats
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/sys/performance/all-stats | jq .

# fetch tmm cpu value from entries
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/sys/tmm-info/stats | jq .

# fetch throughput value from entries
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/sys/traffic/stats | jq .

# get list of services
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/sys/service | jq .