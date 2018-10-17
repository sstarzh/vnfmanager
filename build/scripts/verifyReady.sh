#!/bin/bash

# verify BIG-IP onboarding using iControl REST
# remote BIG-IP address
host='192.168.1.1'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# verify mcp ready
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/sys/mcp-state | grep 'running'

# verify networking (self IP exists)
# we can replace 'self_' prefix with the actual self IP name
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/net/self | grep 'self_'

# verify license
curl -ku $user:$passwd --connect-timeout 10 https://$host:$dfl_mgmt_port/mgmt/tm/sys/license | grep 'registrationKey'