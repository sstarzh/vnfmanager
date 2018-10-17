#!/bin/bash

# revoke a license from BIG-IP using BIG-IQ (unmanaged pool, reachable device)
# remote BIG-IQ address
bigiq_host='192.168.1.2'
dfl_mgmt_port='443'
user='admin'
passwd='admin'

# the taskId is returned by the BIG-IQ rest API license assign/revoke; pass it here to get the task status
taskId='d717c6a1-f3bd-46cb-8410-c6fda58940b9'

# wait for the value of the response .status key to be 'FINISHED'
response_code='STARTED'
until [ $response_code == 'FINISHED' ]
do
	response_code=$(curl -kvu $user:$passwd 'https://$bigiq_host:$dfl_mgmt_port/mgmt/cm/device/tasks/licensing/pool/member-management/$taskId' | jq .status)
done