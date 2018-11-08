Part VI. Configuration change
=============================

1. :ref:`Check existing FW config <existing>`
2. :ref:`Configuration change workflow <as3_change>`
3. :ref:`Check VNF BIG-IP config and run test traffic <as3_check>`


VNF Manager allows users to perform BIG-IP configuration change by invoking `nsd_xxx` Workflow and passing corresponding AS3 payload.
This lab contains a modified AS3 payload that will provision AFM policy and rules for Firewall layer of Gilan blueprint.


.. _existing:


Step 1. Check Existing VNF BIG-IP configuration
-----------------------------------------------

Check VNF BIG-IP FW rules and configuration. There should be no policy or rules configured

1. Check **Master** VNF BIG-IP Management IP in Openstack Horizon UI:

:guilabel:`Project` --> :guilabel:`Compute` --> :guilabel:`Instances`

2. Point the browser to .40 IP of **Master** VNF BIG-IP and login as admin

3. Navigate to :guilabel:`Security` --> :guilabel:`Network Firewall` --> :guilabel:`Active Rules`

.. image:: images/after_as3.png FIX THIS


.. _as3_change:


Step 2. Apply updated AS3 configuration
---------------------------------------

1. To change the AFM configuration, open `as3_update.yaml` on jumphost Desktop and copy it's contents

2. Select :guilabel:`Deployments` --> :guilabel:`nsd_vnf_xxxx` Blueprint 

3. Expand |menuIcon_deploy|, click :guilabel:`Gilan update as3 nsd`, paste the entire AS3 payload copied from the file, and then click :guilabel:`Execute`.

.. |menuIcon_deploy| image:: images/menuIcon.png

.. image:: images/as3_update.png


For more information about Install Workflow see:
:doc:`Update FW layer configuration Workflow <CM-AS3-update>`


AS3 payload for configuration of Firewall rules

.. code-block:: yaml

    class: AS3
    action: deploy
    persist: true
    declaration:
        class: ADC
        schemaVersion: 3.0.0
        id: cfy_vnf_01
        label: vnf
        remark: VNF
        f5vnf:
            class: Tenant
            Shared:
                class: Application
                template: shared
                fwAllowedAddressList:
                    addresses:
                        - 10.0.0.0/8
                        - 172.20.0.0/16
                        - 192.168.0.0/16
                    class: Firewall_Address_List
                fwAllowedPortList:
                    class: Firewall_Port_List
                    ports:
                        - 8080-8081
                        - 22
                        - 443
                        - 53
                        - 80
                fwDefaultDenyAddressList:
                    addresses:
                        - 0.0.0.0/0
                    class: Firewall_Address_List
                fwLogDestinationHsl:
                    class: Log_Destination
                    distribution: adaptive
                    pool:
                        use: poolHsl
                    protocol: tcp
                    type: remote-high-speed-log
                fwLogDestinationSyslog:
                    class: Log_Destination
                    format: rfc5424
                    remoteHighSpeedLog:
                        use: fwLogDestinationHsl
                    type: remote-syslog
                fwLogPublisher:
                    class: Log_Publisher
                    destinations:
                        - use: fwLogDestinationSyslog
                fwPolicy:
                    class: Firewall_Policy
                    rules:
                        -
                            use: fwRuleList
               fwRuleList:
                    class: Firewall_Rule_List
                    rules:
                        -
                            action: accept
                            destination:
                                portLists:
                                    -
                                        use: fwAllowedPortList
                            loggingEnabled: true
                            name: tcpAllow
                            protocol: tcp
                            source:
                                addressLists:
                                    - use: fwAllowedAddressList
                        -
                            action: accept
                            loggingEnabled: true
                            name: udpAllow
                            protocol: udp
                            source:
                                addressLists:
                                    - use: fwAllowedAddressList
                        -
                            action: drop
                            loggingEnabled: true
                            name: defaultDeny
                            protocol: any
                            source:
                                addressLists:
                                    - use: fwDefaultDenyAddressList
                fwSecurityLogProfile:
                    class: Security_Log_Profile
                    network:
                        logIpErrors: true
                        logRuleMatchAccepts: true
                        logRuleMatchDrops: true
                        logRuleMatchRejects: true
                        logTcpErrors: true
                        logTcpEvents: true
                        logTranslationFields: true
                        publisher:
                            use: fwLogPublisher
                        storageFormat:
                            fields:
                                - action
                                - bigip-hostname
                                - context-name
                                - context-type
                                - date-time
                                - dest-ip
                                - dest-port
                                - drop-reason
                                - protocol
                                - src-ip
                                - src-port
                poolHsl:
                    class: Pool
                    members:
                        -
                            enable: true
                            serverAddresses:
                                - 255.255.255.254
                            servicePort: 514
                    monitors:
                        -
                            bigip: /Common/udp
                lbSelectedRule:
                    class: iRule
                    iRule: when LB_SELECTED {log local0. "Selected server [LB::server]"}
                    remark: Log load balanced server
                cpu_killer:
                    remark: Log load balanced server
                    iRule: "when HTTP_REQUEST {\r\nif {[IP::addr [IP::client_addr] equals 10.1.20.20]} {\r\n# Do nothing and forward traffic to server\r\nlog local0. \"Source IP is 10.1.20.20 - Forwarding to destination...\" \r\nreturn\r\n} else {\r\n    # Kill CPU Cycles\r\n    log local0. \"Running CPU killer and responding locally...\"\r\n    set count 10\r\n    for {set i 0} { $i < $count } {incr i} {\r\n        set keys [CRYPTO::keygen -alg rsa -salthex 0f0f0f0f0f0f0f0f0f0f -len 1024]\r\n        set pub_rsakey [lindex $keys 0]\r\n        set priv_rsakey [lindex $keys 1]\r\n        set data [string repeat \"rsakeygen1\" 11]\r\n        set enc_data [CRYPTO::encrypt -alg rsa-pub -key $pub_rsakey $data]\r\n        HTTP::header insert rsa_encrypted \"$enc_data\"\r\n        set dec_data [CRYPTO::decrypt -alg rsa-priv -key $priv_rsakey $enc_data]\r\n    }\r\n\t# Set some basic response headers\r\n\tset server_name \"BIG-IP ($static::tcl_platform(machine))\"\r\n\tset conn_keepalive \"Close\"\r\n\tset content_type \"text\/plain; charset=us-ascii\"\r\n    # initialize response page\r\n    set page \"[clock format [clock seconds] -format {%A %B,%d %Y - %H:%M:%S (%Z)}]\\r\\n\"\r\n\tappend page \"Hello!\\r\\n\"\r\n    # return response page\r\n    HTTP::respond 200 content ${page} noserver Server ${server_name} Connection ${conn_keepalive} Content-Type $content_type\r\n}\r\n}\r\n"
                    class: iRule
                profileL4:
                    class: L4_Profile
                serviceAddress:
                    class: Service_Address
                    arpEnabled: False
                    spanningEnabled: True
                    virtualAddress: 0.0.0.0
                firewall_any:
                    class: Application
                    template: generic
                serviceMain:
                    allowVlans:
                        - bigip: /Common/pgw_dag_net
                    class: Service_Generic
                    iRules:
                        - /f5vnf/Shared/lbSelectedRule
                    layer4: any
                    policyFirewallEnforced:
                        use: /f5vnf/Shared/fwPolicy
                    profileL4:
                        use: /f5vnf/Shared/profileL4
                    securityLogProfiles:
                        - use: /f5vnf/Shared/fwSecurityLogProfile
                    snat: none
                    lastHop: disable
                    translateServerAddress: false
                    translateServerPort: false
                    virtualAddresses:
                        - use: /f5vnf/Shared/serviceAddress
                    virtualPort: 0
            f5_http:
              class: Application
              template: http
              serviceMain:
                allowVlans:
                - bigip: /Common/pgw_dag_net
                translateServerAddress: false
                layer4: tcp
                profileHTTP:
                  bigip: /Common/http
                virtualPort: 0
                iRules:
                - /f5vnf/Shared/lbSelectedRule
                - /f5vnf/Shared/cpu_killer
                translateServerPort: false
                profileL4:
                  use: /f5vnf/Shared/profileL4
                virtualAddresses:
                - use: /f5vnf/Shared/serviceAddress
                snat: none
                lastHop: disable
                policyFirewallEnforced:
                  use: /f5vnf/Shared/fwPolicy
                securityLogProfiles:
                  - use: /f5vnf/Shared/fwSecurityLogProfile
                class: Service_HTTP
            f5_inbound:
              class: Application
              template: generic
              serviceMain:
                allowVlans:
                - bigip: /Common/pdn_dag_net
                class: Service_Generic
                iRules:
                - /f5vnf/Shared/lbSelectedRule
                layer4: any
                profileL4:
                  use: /f5vnf/Shared/profileL4
                snat: none
                translateServerAddress: False
                translateServerPort: False
                virtualAddresses:
                - use: /f5vnf/Shared/serviceAddress
                virtualPort: 0

.. _as3_check:


Step 3. Validate configuration change
-------------------------------------

1. Check VNF BIG-IP configuration
:guilabel:`Security` --> :guilabel:`Network Firewall` --> :guilabel:`Active Rules`

.. image:: images/after_as3.png FIX THIS


2. Run test traffic through Gilan to ensure Firewall configuration doesn't block the flow.

:doc:`Run test traffic <test>`


What’s Next?

:doc:`(Optional) Run Uninstall workflow <uninstall>`