Sample Gi LAN Inputs File
=========================

You will copy and paste the following code sample into a new YAML file you will use for the *Gi LAN Solution*. Then you will change the values according to your implementation, and save it locally.
Once completed, you will |uploadFile_gi-inputs| into VNFM to auto-complete the F5 blueprint. Learn more about these |definitions_gi-inputs|.


.. |uploadFile_gi-inputs| raw:: html

    <a href="https://clouddocs.f5networks.net/cloud/nfv/latest/deploy.html#step-7-deploy-local-f5-gilan-blueprint">upload this inputs file</a>


.. |definitions_gi-inputs| raw:: html

    <a href="https://clouddocs.f5networks.net/cloud/nfv/latest/deploy.html#gi-lan-blueprint">parameter descriptions</a>


.. code-block:: yaml

 # VNF Resource Information Collector inputs for Reporting
 ric_purchasing_model: subscription                             # perpetual or subscription
 ric_throughput: '5'                                            # 5, 10, or 50 Gbps total throughput for a layer
 ric_vnfm_serial: '12345'                                       # Serial Number from purchasing email

 # VNF specific inputs
 auto_last_hop: "disabled"                                      # disables last_hop on VNF and creates inbound VS on DAG when No CGNAT, or when CGNAT is not F5 BIG-IP
 default_gateway: 10.1.52.1                                     # The default gateway the VNF should use to reach the Internet

 ####    Scaling Thresholds and Values   ############################################################################
 # Maximum number of 'instances' that can be created during scale out
 max_scale_dag_group: '1000'                                    # Max Dag Group Members
 max_scale_vnf_group: '1000'                                    # Max VNF Group Members

 # Max number of times that a heal can be tried before giving up.
 max_heal_vnfd_dag_ve: '5'
 max_heal_vnf_layer: '5'
 max_heal_vnf_slave_ve: '5'

 # VNF Layer scaling inputs
 vnf_layer_cpu_threshold: '15'                                  # percent of aggregated CPU for when to scale the next slave member
 vnf_layer_cpu_threshold_check_interval: '1'                    # number of seconds between checks .5 is possible

 # VNF Group scaling inputs
 vnf_group_throughput: '10'                                     # 5, 10 or 50 total agregated Gbps for entire layer
 vnf_group_throughput_threshold: '50'                           # percent of aggregated CPU for when to scale the next layer
 vnf_group_throughput_check_interval: '1'                    # number of seconds between checks .5 is possible

 # DAG Group scaling inputs
 dag_group_cpu_threshold: '50'                                # percent of aggregated CPU for when to scale the next dag member
 dag_group_cpu_threshold_check_interval: '1'                 # number of seconds between checks .5 is possible

 ####################################################################################################################

 # Nagios inputs
 floating_network_id: <changeMe>                             # OpenStack ID of the floating IP network (extnet)
 centos_image_id: dd291320-035b-479f-9e98-e05c6d7c44d2       # OpenStack ID of the CentOS image to use for the monitoring nodes
 nagios_flavor_id: 5371c5f1-2496-4862-a0ea-b740b7000162      # OpenStack ID of the flavor to use for the monitoring nodes

 # Common inputs
 bigip_os_ssh_key: jumphost                                  # OpenStack SSH Key Name
 cm_ip: <changeMe>                                           # The management IP address (.40 subnet) of the VNF Manager

 # Software references for the BIG-IP VE
 sw_ref_dag:
     data:
         image: BIG-IP-13.1.0.7                              # OpenStack Image Name
         flavor: m1.large                                    # OpenStack Flavor Name
     revision: 0
 sw_ref_vnf:
     data:
         image: BIG-IP-13.1.0.7                              # OpenStack Image Name
         flavor: m1.large                                    # OpenStack Flavor Name
     revision: 0

 # BIG-IQ License Manager
 big_iq_host: 10.1.20.14                                     # Management IP address of the BIG-IQ License Manager
 big_iq_lic_pool: regkeys                                 # Pool Name containing the BIG-IP VE Licenses created on the BIG-IQ from the Reg Key provided in the Email from F5

 # BGP Router Config
 bgp_dag_pgw_peer_ip: 10.1.55.201                              # IP address of the PGateway router use for BGP Neighbor command
 bgp_vnf_pgw_peer_ip: 10.1.55.201                            # IP address of the PGateway router that the VNF will use to route traffic back to the UE devices
 bgp_pgw_peer_as: '200'                                      # Autonomous System (AS) number of the PGateway BGP router
 bgp_dag_egw_peer_ip: 10.1.52.201                             # IP address of the External Gateway router that the DAG will advertise to to send traffic back to the UE devices
 bgp_egw_peer_as: '300'                                      # Autonomous System (AS) number of the External Gateway BGP router


 # Security Groups In OpenStack
 ctrl_sg_name: control_sg
 mgmt_sg_name: mgmt_sg
 pgw_sg_name: pgw_sg
 pdn_sg_name: pdn_sg
 snmp_sg_name: snmp_sg

 # Networks and Subnets in OpenStack
 mgmt_net: mgmt
 mgmt_subnet: mgmt_subnet
 pgw_net: pgw_net
 pgw_subnet: pgw_net_subnet
 pdn_net: pdn_net
 pdn_subnet: pdn_net_subnet
 pgw_dag_net: pgw_dag_net
 pgw_dag_subnet: pgw_dag_subnet
 pdn_dag_net: pdn_dag_net
 pdn_dag_subnet: pdn_dag_subnet
 ctrl_net: control
 ctrl_subnet: control_subnet
 ha_net: ha_net
 ha_subnet: ha_subnet
 pgw_dag_subnet_cidr: 10.1.55.0/24
 pgw_dag_subnet_mask: '/24'
 pdn_dag_subnet_cidr: 10.1.52.0/24

 #####################################################################################
 # Configuration of the F5 VNF Service Layers in AS3 Declaration format              #
 #    Example: Your Firewall Configuration.                                          # 
 #    Example: Your Subscriber based Policy enforcement Configuration.               #
 # The format of this YAML is critical, please use a YAML linter, and double check   #
 # the spelling of keys and values.  If any of the declaration is incorrect, an HTTP #
 # 422 error will be seen the deployment logs.                                       #
 #####################################################################################
 vnf_as3_nsd_payload:
   class: AS3
   action: deploy
   persist: True
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