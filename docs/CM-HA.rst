
High Availability Guide
=======================

Environment
-----------

Hardware prerequisite
``````````````````````

F5 VNFM HA cluster usually builds on three F5 VNF managers. Each
F5 VNF manager requires at least next hardware resources:

+---------+---------+-------------+
|         | Minimum | Recommended |
+=========+=========+=============+
| vCPU    | 2       | 8           |
+---------+---------+-------------+
| RAM     | 4GB     | 16GB        |
+---------+---------+-------------+
| Storage | 5GB     | 64GB        |
+---------+---------+-------------+

The minimum requirements are enough for small deployments that only
manage a few compute instances. Managers that manage more deployments or
large deployments need at least the recommended resources.

Recommended resource requirements are tested and verified to be
dependent on these criteria:

-  Blueprints: The only limit to the number of blueprints is the storage required to store the number and size of the local blueprints.
-  Deployments: Each deployment requires minimal storage.
-  Nodes: F5 VNFM can orchestrate 12,000 non-monitored nodes (tested with 2000 deployments, each spanning six node instances). Monitored nodes add CPU load to the manager and require storage for the logs, events and metrics.
-  Tenants: You can run up to 1000 tenants on a manager.
-  Workflows & Concurrency: You can run up to 100 concurrent workflows.
-  Logs, events and metrics: You must have enough storage to store the logs, events and metrics sent from the hosts. You can configure :doc:`log rotation <CM-logRotation>` to reduce the amount of storage space required.

Software prerequisite
`````````````````````

F5 VNF Manager is supported for installation on a 64-bit host with
RHEL/CentOS 7.4.

There are specific packages that are commonly included in RHEL/CentOS.
You must have these packages installed before you install F5 VNFM
Manager:

-  sudo - Required to run commands with root privileges (note that this
   is still a requirement even when running with root user)
-  openssl-1.0.2k - Required to generate internal/external certificates
-  openssh-server - Required for creating SSH keys during the sanity
   check
-  logrotate - Required for rotating F5 VNFM log files
-  systemd-sysv - Required by PostgreSQL DB
-  initscripts - Required by RabbitMQ
-  which - Required to install Logstash plugins
-  python-setuptools - Required by Python
-  python-backports - Required by Python
-  python-backports-ssl_match_hostname - Required by Python

Network Interfaces
``````````````````

F5 VNF Manager requires at least two network interfaces:

-  **Private** - Dedicated for communication with other F5 VNFM components, including agents and cluster members.
-  **Public** - Dedicated for connections to the F5 VNF Manager with the F5 VNFM CLI and Web Interface.

In some cases, it is possible to use only one network interface, but
this can lead to security problems.

Network Ports Requirements
``````````````````````````

**VNF Manager single node**

+-----------+----------------+-----------+--------+-------------------+
| Source    | <->            | Target    | Port   | Description       |
+===========+================+===========+========+===================+
| F5 VNF    | <->            | F5 VNF    | 8300   | Internal port for |
| Manager   |                | Manager   |        | the distributed   |
|           |                |           |        | key/value store.  |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 8301   | Internal port for |
| Manager   |                | Manager   |        | TCP and UDP       |
|           |                |           |        | heartbeats. Must  |
|           |                |           |        | be accessible for |
|           |                |           |        | both TCP and UDP. |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 8500   | Port used for     |
| Manager   |                | Manager   |        | outage recovery   |
|           |                |           |        | in the event that |
|           |                |           |        | half of the nodes |
|           |                |           |        | in the cluster    |
|           |                |           |        | failed.           |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 22000  | Filesystem        |
| Manager   |                | Manager   |        | replication port. |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 15432  | Database          |
| Manager   |                | Manager   |        | replication port. |
+-----------+----------------+-----------+--------+-------------------+

**Cloudify Manager HA cluster**

+-----------+----------------+-----------+--------+-------------------+
| Source    | <->            | Target    | Port   | Description       |
+===========+================+===========+========+===================+
| F5 VNF    | <->            | F5 VNF    | 8300   | Internal port for |
| Manager   |                | Manager   |        | the distributed   |
|           |                |           |        | key/value store.  |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 8301   | Internal port for |
| Manager   |                | Manager   |        | TCP and UDP       |
|           |                |           |        | heartbeats. Must  |
|           |                |           |        | be accessible for |
|           |                |           |        | both TCP and UDP. |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 8500   | Port used for     |
| Manager   |                | Manager   |        | outage recovery   |
|           |                |           |        | in the event that |
|           |                |           |        | half of the nodes |
|           |                |           |        | in the cluster    |
|           |                |           |        | failed.           |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 22000  | Filesystem        |
| Manager   |                | Manager   |        | replication port. |
+-----------+----------------+-----------+--------+-------------------+
| F5 VNF    | <->            | F5 VNF    | 15432  | Database          |
| Manager   |                | Manager   |        | replication port. |
+-----------+----------------+-----------+--------+-------------------+

Create hosts
------------

Openstack platform
``````````````````

1. Create separated security groups for public and private connections based on tables described below.

2. Create or import key pairs for managers and agents.

3. Create three RHEL/CentOS 7.4 instances with flavors that meet F5 VNFM requirements described below.

4. Either add private and public networks or only one network to F5 VNF manager instances.

5. Associate floating IP if this is needed for every instance.

6. Assign security groups to the instances.

VMware infrastructure
``````````````````````

Create three RHEL/CentOS 7.4 VMs. Add two network interfaces and assign
private and public networks, or only one network interface and one
network.

Install F5 VNF managers
-------------------------

The following actions should be performed on all servers:

1. Add the user to the group wheel and install F5 VNF-manager-install
   package.

    .. code-block:: bash

       sudo usermod -a -G wheel $(whoami)
       sudo yum install -y  [need install F5 vnfm install path]

2. To change the default configuration settings, edit the
   ``/etc/vnfm/config.yaml`` file. Next parameters can be changed:

   -  Administrator password (``admin_password``)

      *If you do not specify an administrator password in the command
      options or the config.yaml file, the installation process
      generates a random password and shows it as output when the
      installation is complete.*

   -  Private and public IP addresses (``private_ip;public_ip``)

      *In case of only one assigned IP address, ``public_ip`` and
      ``private_ip`` parameters should have the same IP address.*

   -  External REST communications over HTTPS (``ssl_enabled``)
   -  Local path replacement for remote resources with a URL
      (``import_resolver``)
   -  Multi-network management (``networks``)

      *If a manager has a multiple interfaces, you must list in the
      config.yaml all of the interfaces that agents can connect to. You
      must then specify in each blueprint the interface that the agent
      connects. If no IP address is specified in the blueprint, the
      agent connects to the interface that is identified as the private
      IP in the configuration process, specified by –private-ip or
      specified in the config.yaml file.*

      .. code-block:: console

         agent:
          networks:
          network_a: <ip_address_a>
          network_b: <ip_address_b>

   -  LDAP connection information (``ldap``) Descriptions of parameters
      can be found :doc:`here <CM-ldap>`.

      Example:

      .. code-block:: console

         ldap:
          server: "ldap://<ldap server>:389"
          username: "Administrator"
          password: "Password"
          domain: "domain.com"


   - SSL communication settings (`ssl_inputs`)

3. Run: ``cfy_manager install``

4. For security reasons, we recommend that you:

   -  Specify an administrator password according to your security
      policy
   -  Set SSL in config.yaml to enabled
   -  Set gunicorn to bind to localhost To set gunicorn to listen on
      localhost only:

      1. Edit the \ ``/usr/lib/systemd/system/vnfm-restservice.service`` file.

      2. Find this line: \ ``-b 0.0.0.0:${REST_PORT} \``

      3. Replace the line with: \ ``-b localhost:${REST_PORT} \``

      4. To restart the dependent services, run next commands:

      .. code-block:: console

         sudo systemctl daemon-reload
         sudo systemctl restart F5 VNFM-restservice

Build F5 VNFM HA cluster
-------------------------

Create a cluster when you completed installing your F5 VNF Managers.
When you run the ``cfy cluster start`` command on a first F5 VNF
Manager, high availability is configured automatically. Use the
``cfy cluster join`` command, following installation, to add more
F5 VNF Managers to the cluster. The F5 VNF Managers that you join to
the cluster must be in an empty state, otherwise the operation will
fail.

1. Add profiles of all three F5 VNF managers on F5 VNFM cli:

   .. code-block:: console

      cfy profiles use <Leader IP> -t default_tenant -u admin -p <admin password>
      cfy profiles use <Replica1 IP> -t default_tenant -u admin -p <admin password>
      cfy profiles use <Replica2 IP> -t default_tenant -u admin -p <admin password>

2. Start cluster:

   .. code-block:: console

      cfy profiles use <Leader IP>
      cfy cluster start --cluster-node-name <Leader name>

3. Switch to second profile:

   .. code-block:: console

      cfy profiles use <Replica1 IP>

4. Join the manager to the cluster:

   .. code-block:: console

      cfy cluster join --cluster-node-name <Replica1 name> <Leader IP>

5. Switch to third profile:

   .. code-block:: console

      cfy profiles use <Replica2 IP>

6. Join the manager to the cluster:

   .. code-block:: console

      cfy cluster join --cluster-node-name <Replica2 name> <Leader IP>

Create VIP for F5 VNFM HA cluster
----------------------------------

1. Install HAproxy

   .. code-block:: console

      sudo yum install haproxy

2. Make folder: ``/etc/haproxy/certs.d/``

3. Creating a Combined PEM SSL Certificate/Key File

   .. code-block:: console

      cat example.com.crt example.com.key >/etc/haproxy/certs.d/example.com.pem

4. Configure ``/etc/haproxy/haproxy.cfg``

   Obtain the base64 representation for the authorization header:

   .. code-block:: console

      echo -n "admin:admin" | base64

   Example for SSL REST:

   .. code-block:: console

      frontend https_front
          bind *:443 ssl crt /etc/haproxy/certs.d/second_all.pem no-sslv3
          option http-server-close
          option forwardfor
          reqadd X-Forwarded-Proto:\ https
          reqadd X-Forwarded-Port:\ 443

          # set HTTP Strict Transport Security (HTST) header
          rspadd  Strict-Transport-Security:\ max-age=15768000
          default_backend https_back

      backend https_back
          balance roundrobin
          option httpchk GET /api/v3.1/status HTTP/1.0\r\nAuthorization:\ Basic\ YWRtaW46YWRtaW4=
          http-check expect status 200
          server server_name_1 10.1.1.41:443 check ssl verify none
          server server_name_2 10.1.1.42:443 check ssl verify none

   Example for non-SSL REST:

   .. code-block:: console

      frontend http_front
          bind *:80
          default_backend http_back

      backend http_back
          balance roundrobin
          option httpchk GET /api/v3.1/status HTTP/1.0\r\nAuthorization:\ Basic\ YWRtaW46YWRtaW4=
          http-check expect status 200
          server server_name_1 10.1.1.41:80 check
          server server_name_2 10.1.1.42:80 check

In this examples, 10.1.1.41 and 10.1.1.42 are the public IP addresses of the F5 VNF Manager cluster nodes and “YWRtaW46YWRtaW4=” is the result of the command above.

F5 VNFM HA cluster management
------------------------------

F5 VNFM HA cluster manages in the same way as a single F5 VNF
manager, but there are small differences when a leader changing.

F5 VNFM CLI profile contains all information about managers of the HA
Cluster and if the leader manager does not answer F5 VNFM CLI starts
finding new leader.

If new profile is created for existing cluster, or new nodes joined to
the cluster the command should be run to retrieve the information about
all cluster managers and upgrade the profile:

.. code-block:: console

   cfy cluster update-profile

When using F5 VNFM WEB UI - F5 VNFM HA cluster does not provide out of
the box mechanism to update the WEB UI to switch to a new leader due to
Security limitations. F5 VNFM WEB UI User should make sure to have a
mechanism to be aware which F5 VNF Manager is the current leader.
There are several well known mechanisms to achieve this, for example
using a Load Balancer, using a Proxy such as HAProxy and configure it to
poll the cluster IPs, or using a CNAME instead of explicit IPs.

You can also implement a |LdBl_CM-HA|.

.. |LdBl_CM-HA| raw:: html

    <a href="https://clouddocs.f5networks.net/cloud/nfv/latest/CM-UseHAcluster.html#using-a-load-balancer" target="_blank">load balancer health check</a>


What's Next?

:doc:`Using Clusters to Provide High Availability <CM-UseHAcluster>`

