VNF Manager deployment Prerequisites
====================================

Upon purchasing a VFNM solution, customer will receive an email with a VNFM install package download URL, as well as an associated product license key,
which is used only for obtaining support.
For the purpose of this lab, VNFM package has already been downloaded and stored in Openstack Glance. To learn more about Glance procedures, see |glance|

Prerequisites
---------------

In addition to the VNFM install package, the following supported components have been downloaded from |F5dwnlds_setup| and stored in Glance:

-  |bigIQ_setup| and F5-BIQ-VE-LIC-MGR-LIC license key--This activates the BIG-IQ |LicMgr_setup| utility that manages licensing for BIG-IPs (utility pools) during orchestration.
-  |bigIP_setup| and F5-BIG-MSP-LOADV6-LIC license key--Use the Utility License, |autoLic_setup| (if connected to the Internet) or the |manLic_setup| (if not connected).

F5 VNFM Solutions
--------------------

F5 offers the following VNFM solutions with built-in services. This lab uses Gi LAN Solution Blueprint

+------------------------+-------------------------------------------------------------------------------------------------------------------+
| Solution               | Description                                                                                                       |
+========================+===================================================================================================================+
| Gi LAN                 | VNFM is comprised of an F5 blueprint with specific parameters plus a Gi LAN inputs YAML file that defines those   |
|                        | parameters with your system requirements. These components use plugins, enabling you to automatically deploy all  |
|                        | the necessary pieces to create a highly-available set of services, deployed in service layers. These layers       |
|                        | auto-scale virtual machines and services to provide a complete and fully configured lifecycle management workflow:|
|                        |                                                                                                                   |
|                        | 1.  Install (push button)                                                                                         |
|                        | 2.  Auto-Scale (out and in)                                                                                       |
|                        | 3.  Auto-Heal (with quarantine of instances for troubleshooting)                                                  |
|                        | 4.  Update (push button)                                                                                          |
|                        | 5.  Upgrade (push button)                                                                                         |
|                        | 6.  Delete (push button)                                                                                          |
|                        |                                                                                                                   |
+------------------------+-------------------------------------------------------------------------------------------------------------------+
| Gi Firewall            | VNFM is comprised of an F5 blueprint with specific parameters plus this solution also uses the same Gi LAN inputs |
|                        | YAML file as the previous solution, which defines those parameters with your system requirements. These           |
|                        | components use plugins enabling you to utilize firewall protection services only like, DDoS mitigation, DNS       |
|                        | security, and intrusion protection                                                                                |
+------------------------+-------------------------------------------------------------------------------------------------------------------+
| VNFM Base              | VNFM is comprised of a base F5 blueprint and a base inputs YAML file, lacking monitoring and resource collecting  |
|                        | parameters, plus a VNFM Base inputs file that defines those base parameters with your system requirements.        |
+--------------------------------------------------------------------------------------------------------------------------------------------+


F5 blueprint
------------
A blueprint is a model of your application’s topology and its operations implementation written in a YAML Domain
Specific Language (DSL). The F5 blueprint defines all node types and the relationship between each node,
for example:

.. code-block:: yaml

   imports:
    - gilan_vnfd.yaml

    inputs:
      pgw_min_instance_number:
      type: integer
      default: 1
    pgw_max_instance_number:
    type: integer
    default: 1000

   pdn_min_instance_number:
    type: integer
    default: 1
   pdn_max_instance_number:
    type: integer
    default: 1000

   vnf_min_instance_number:
    type: integer
    default: 1
   vnf_max_instance_number:
    type: integer
    default: 1000

   node_templates:

   pgw_lbs_ve_config:
    type: f5.gilan.nodes.Configuration
    properties:
      port: 443
      ssl: true
      verify: false
    interfaces:
      cloudify.interfaces.lifecycle:
        configure:
          inputs:
            template_file: templates/check-all-services.yaml
            params:
              username: { get_secret: bigip_username }
              password: { get_secret: bigip_admin_password }
              host: { get_attribute: [ SELF, target_host_ip ] }
    relationships:
      - type: cloudify.relationships.contained_in
        target: pgw_lbs_ve
        source_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            preconfigure:
              implementation: gilan.gilan_plugin.relationship_lifecycle.copy_runtime_properties
              inputs:
                properties:
                  - value: {get_attribute: [TARGET, ip]}
                    name: target_host_ip
      - type: cloudify.relationships.depends_on
        target: pgw_lbs_ve_revoke_license


-  **Nodes**—-all components in your network are listed in the nodes section (YAML list) in the blueprint YAML file, which
   defines the application topology of those components and the relationship between them.
-  **Workflows**—-the different automation processes for the application are defined in the workflow section of the blueprint
   YAML file. Workflows are orchestration algorithms written in an executable language (for example, Python) using dedicated, APIs. VNFM workflows are delivered by way of plugins.
-  **Plugins**-—communicate with external services, such as: cloud services like OpenStack, container-management systems like
   Kubernetes, configuration management tools like Ansible, and other communication protocols like HTTP and SSH.


What’s Next?

:doc:`Deploy VNFM orchestration <deploy>`


.. |F5dwnlds_setup| raw:: html

    <a href="https://downloads.f5.com/esd/productlines.jsp" target="_blank">downloads.f5.com</a>

.. |bigIQ_setup| raw:: html

    <a href="https://support.f5.com/kb/en-us/products/big-iq-centralized-mgmt/releasenotes/product/relnote-big-iq-central-mgmt-6-0-1.html" target="_blank">BIG-IQ 6.0.1</a>

.. |LicMgr_setup| raw:: html

    <a href="https://support.f5.com/kb/en-us/products/big-iq-centralized-mgmt/manuals/product/big-iq-centralized-management-device-6-0-1/04.html#guid-e65183a0-e0b7-4b8a-a590-61c832b5c6f1" target="_blank">License Manager</a>

.. |bigIP_setup| raw:: html

    <a href="https://downloads.f5.com/esd/product.jsp?sw=BIG-IP&pro=big-ip_v13.x" target="_blank">BIG-IP 13.1.1</a>

.. |autoLic_setup| raw:: html

    <a href="https://support.f5.com/kb/en-us/products/big-iq-centralized-mgmt/manuals/product/big-iq-centralized-management-device-6-0-1/04.html#GUID-27148D9A-7A2B-41C4-A03E-26CE4CCB0697" target="_blank">automatic method</a>

.. |manLic_setup| raw:: html

    <a href="https://support.f5.com/kb/en-us/products/big-iq-centralized-mgmt/manuals/product/big-iq-centralized-management-device-6-0-1/04.html#GUID-AB197651-BEDA-4A46-8EFF-59EFE928E418" target="_blank">manual method</a>

.. |glance| raw:: html

    <a href="https://docs.openstack.org/glance/pike" target="_blank">Openstack Glance</a>
