Sample Gi LAN Inputs File
=========================

You will copy and paste the following code sample into a new YAML file you will use for the *Gi LAN Solution*. Then you will change the values according to your implementation, and save it locally.
Once completed, you will |uploadFile_gi-inputs| into VNFM to auto-complete the F5 blueprint. Learn more about these |definitions_gi-inputs|.


.. |uploadFile_gi-inputs| raw:: html

    <a href="https://clouddocs.f5networks.net/cloud/nfv/latest/deploy.html#step-7-deploy-local-f5-gilan-blueprint">upload this inputs file</a>


.. |definitions_gi-inputs| raw:: html

    <a href="https://clouddocs.f5networks.net/cloud/nfv/latest/deploy.html#gi-lan-blueprint">parameter descriptions</a>


.. code-block:: yaml

  # Gilan inputs
  pgw_dag_subnet_mask: '/24'
  big_ip_root_user: root
  default_gateway: 10.1.52.1
  blueprint_name: "F5-VNF-Service-Layer_v0282-devel"
  # VNF Resource Information Collector inputs
  ric_throughput: "5"
  ric_purchasing_model: subscription
  ric_licensing: gilan
  ric_vnfm_license: "12345"
  auto_last_hop: "disabled"

  # VNF inputs
  ctrl_net: control
  ctrl_subnet: control_subnet
  ha_net: ha_net
  ha_subnet: ha_subnet

  # Nagios inputs
  floating_network_id: <changeMe>
  centos_image_id: dd291320-035b-479f-9e98-e05c6d7c44d2
  nagios_flavor_id: 5371c5f1-2496-4862-a0ea-b740b7000162

  vnf_scale_out_threshold_for_sysStatClientServerBytesInOut: "250000"
  dag_scale_out_threshold_for_sysGlobalTmmStatTmUsageRatio1m: "99"
  vnf_scale_out_threshold_for_sysGlobalTmmStatTmUsageRatio1m: "99"

  vnf_check_interval_for_sysStatClientServerBytesInOut: "1"
  vnf_check_interval_for_sysGlobalTmmStatTmUsageRatio1m: "1"
  dag_check_interval_for_sysGlobalTmmStatTmUsageRatio1m: "1"

  # New since 0.2.24.0
  vnf_group_throughput_threshold: "75"
  vnf_group_throughput: "10"
  vnf_layer_cpu_threshold: "75"
  dag_group_cpu_threshold: "75"
  vnf_layer_cpu_threshold_check_interval: "1"
  vnf_group_throughput_check_interval: "1"
  dag_group_cpu_threshold_check_interval: "1"
  min_scale_dag_group: "1"
  max_scale_dag_group: "1000"
  min_scale_vnf_layer: "1"
  max_scale_vnf_layer: "31"
  min_scale_vnf_group: "1"
  max_scale_vnf_group: "1000"
  max_heal_vnf_layer: "5"
  max_heal_vnfd_dag_ve: "5"
  max_heal_vnf_slave_ve: "5"

  # Common inputs
  cm_ip: <changeMe>
  sw_ref_dag:
    data:
      image: BIG-IP-13.1.0.7
      flavor: m1.large
    revision: 0
  sw_ref_vnf:
    data:
      image: BIG-IP-13.1.0.7
      flavor: m1.large
    revision: 0
  bigip_os_ssh_key: jumphost

  big_iq_host: 10.1.20.14
  big_iq_lic_pool: regkeys

  ctrl_sg_name: control_sg
  mgmt_sg_name: mgmt_sg
  pgw_sg_name: pgw_sg
  pdn_sg_name: pdn_sg
  snmp_sg_name: snmp_sg

  mgmt_net: mgmt
  mgmt_subnet: mgmt_subnet
  mgmt_port: "443"

  pgw_net: pgw_net
  pgw_subnet: pgw_net_subnet
  pdn_net: pdn_net
  pdn_subnet: pdn_net_subnet

  pgw_dag_net: pgw_dag_net
  pgw_dag_subnet: pgw_dag_subnet
  pgw_dag_subnet_cidr: 10.1.55.0/24

  pdn_dag_net: pdn_dag_net
  pdn_dag_subnet: pdn_dag_subnet
  pdn_dag_subnet_cidr: 10.1.52.0/24

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
            profileL4:
              use: /f5vnf/Shared/profileL4
            snat: auto
            lastHop: disable
            translateServerAddress: False
            translateServerPort: False
            virtualAddresses:
            - use: /f5vnf/Shared/serviceAddress
            virtualPort: 0
        firewall_fastL4:
          class: Application
          template: l4
          serviceMain:
            class: Service_L4
            layer4: tcp
            allowVlans:
              - bigip: /Common/pgw_dag_net
            profileL4:
              use: /f5vnf/Shared/profileL4
            virtualAddresses:
            - use: /f5vnf/Shared/serviceAddress
            virtualPort: 0
            translateServerAddress: False
            translateServerPort: False
            snat: auto
            lastHop: disable
            iRules:
              - /f5vnf/Shared/lbSelectedRule
        firewall_inbound:
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


