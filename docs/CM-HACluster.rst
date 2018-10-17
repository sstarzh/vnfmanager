
High Availability Cluster Upgrade Guide
======================================================

Overview
--------

These instructions explain how to upgrade a F5 VNFM High Availablity
(HA) cluster from version 4.x to version 4.3.

Upgrade on new hosts
````````````````````

This is the recommended method. If something happen in upgrade process,
you still have the old manager, working and functioning.

The key elements of upgrading a F5 VNFM HA cluster on new hosts are:

1. Create and download snapshot.

2. Save agent ssh keys.

3. Install new version for master manager on new host.

4. Install new version for standby managers on new host.

5. Restore last snapshot.

6. Reinstall agents.

7. Start cluster on master.

8. Join standby nodes to the HA cluster.

In-place upgrade
````````````````

Upgrading F5 VNFM HA Cluster entails tearing down the existing Managers
and installing a new version of F5 VNF manager on the same hosts. You
can also restore data from your existing instance to new instance.

The key elements of in-place upgrading a F5 VNFM HA cluster are:

1.  Create and download snapshot.

2.  Save ``/etc/VNFM/ssl`` folder of cluster’s master manager.

3.  Save agent ssh keys.

4.  Remove standby nodes from the cluster.

5.  Teardown managers.

6.  Clean managers after teardown.

7.  Install new version on master manager’s host (In-place
    installation).

8.  Install new version on standby managers’ host (In-place
    installation).

9.  Start HA cluster on master manager.

10. Restore last snapshot.

11. Join standby nodes to the HA cluster.

Upgrade F5 VNFM HA cluster
---------------------------

There are two methods to upgrade F5 VNFM HA cluster to version 4.3.

.. _upgrade-on-new-hosts-1:

Upgrade on new hosts
````````````````````

This is the recommended method. If something happen in upgrade process,
you still have the old manager, working and functioning.

Next steps allow you to go through upgrade to new hosts:

1. Create snapshot on old F5 VNFM HA cluster and download it:

    .. code-block:: yaml

       cfy snapshots create my_snapshot  # --include-metrics #(optional)
       cfy snapshots download my_snapshot -o {{ /path/to/the/snapshot/file }}

2. Save SSH keys from /etc/VNFM folder:

    .. code-block:: yaml

       cp –r /etc/VNFM/.ssh <backup_dir>

3. Install new F5 VNFM HA cluster managers to new hosts (see :doc:`HA Build Guide <CM-HA>`).

4. Upload and restore snapshot to new master manager:

    .. code-block:: yaml

       cfy snapshots upload {{ /path/to/the/snapshot/file }} --snapshot-id <snapshot_name>
       cfy snapshots restore <snapshot_name>

5. Reinstall agents:

    .. code-block:: yaml

       cfy agents install --all-tenants

6. Start cluster on master manager

7. Join replicas to the new F5 VNFM HA cluster

8. Delete old cluster’s hosts

.. _in-place-upgrade-1:

In-place upgrade
````````````````

This method allows upgrading F5 VNFM HA cluster on the same hosts. You
would run the risk of not being able to do a rollback should anything
happen. In addition, in-place upgrades only work if the IP, AMQP
credentials and certificates are left unchanged. Otherwise, you will not
be able to communicate with the existing agents.

1. Create a snapshot and download it ``cfy snapshots create my_snapshot # --include-metrics #(optional)     cfy snapshots download my_snapshot -o {{ /path/to/the/snapshot/file }}``

2. Save SSL certificates and SSH key from /etc/VNFM folder ``cp -r /etc/VNFM/ssl <backup_dir>     cp –r /etc/VNFM/.ssh <backup_dir>``

3. Save RabbitMQ credentials. Credentials can be found in next places:

    -  /etc/VNFM/config.yaml
    -  /opt/mgmtworker/work/broker_config.json
    -  /opt/manager/VNFM-rest.conf
    -  /etc/VNFM/cluster

    Default credentials:

    .. code-block:: console

       Username: **admin**
       Password: **admin**

4. Teardown F5 VNF managers. Repeat next steps on each manager:

   Different methods for different version:

   -  4.0 - 4.2:

      .. code-block:: yaml

         curl -o ~/delete_cluster_4_0_1.py https://raw.githubusercontent.com/VNFM-cosmo/VNFM-dev/master/scripts/delete_cluster_4_0_1.py

         sudo python ~/delete_cluster_4_0_1.py

         curl -o ~/cfy_teardown_4_0_0.sh https://raw.githubusercontent.com/VNFM-cosmo/VNFM-dev/master/scripts/cfy_teardown_4_0_0.sh

         sudo bash cfy_teardown_4_0_0.sh -f

   -  4.3.0 - 4.3.1:

      .. code-block:: yaml

         sudo cfy_manager remove -f
         sudo yum remove VNFM-manager-install

         curl -o ~/delete_cluster_4_0_1.py https://raw.githubusercontent.com/VNFM-cosmo/VNFM-dev/master/scripts/delete_cluster_4_0_1.py

         sudo python ~/delete_cluster_4_0_1.py

         curl -o ~/cfy_teardown_4_0_0.sh https://raw.githubusercontent.com/VNFM-cosmo/VNFM-dev/master/scripts/cfy_teardown_4_0_0.sh

         sudo bash cfy_teardown_4_0_0.sh -f

5. Remove CLI profiles of deleted hosts.

   .. code-block:: yaml

      rm -rf ~/.VNFM/profiles/{{ Manager's IP address }}

6. Reboot hosts.

7. (Optional) Fix failed services.

   .. code-block:: yaml

      sudo systemctl daemon-reload
      sudo systemctl reset-failed

8. Install new managers on the same hosts (see :doc:`HA Build Guide <CM-HA>`).

9. Put rabbitmq credentials and path to certificate files from old cluster into ``/etc/VNFM/config.yaml`` before run command
   ``cfy_manager install``:

   .. code-block:: yaml

      rabbitmq:
      username: <username> #must be stored from old CFY HA cluster
      password: <password> #must be stored from old CFY HA cluster
      ssl_inputs:
      external_cert_path: <backup_dir>/ssl/VNFM_external_cert.pem
      external_key_path: <backup_dir>/ssl/VNFM_external_key.pem
      internal_cert_path: <backup_dir>/ssl/VNFM_internal_cert.pem
      internal_key_path: <backup_dir>/ssl/VNFM_internal_key.pem
      ca_cert_path: <backup_dir>/ssl/VNFM_internal_ca_cert.pem
      ca_key_path: <backup_dir>/ssl/VNFM_internal_ca_key.pem
      ca_key_password: ''

10. Create cluster (More information in :doc:`HA Build Guide <CM-HA>`).

   .. code-block:: yaml

      cfy profiles use <Leader IP> -t default_tenant -u admin -p <admin password>
      cfy profiles use <Replica1 IP> -t default_tenant -u admin -p <admin password>
      cfy profiles use <Replica2 IP> -t default_tenant -u admin -p <admin password>
      cfy profiles use <Leader IP>
      cfy cluster start --cluster-node-name <Leader name>

11. Restore the snapshot.

   .. code-block:: yaml

      cfy snapshots upload {/path/to/the/snapshot/file} --snapshot-id <snapshot_name>
      cfy snapshots restore

12. Join replicas to the cluster

   .. code-block:: yaml

      cfy profiles use <Replica1 IP>
      cfy cluster join --cluster-node-name <Replica1 name> <Leader IP>
      cfy profiles use <Replica2 IP>
      cfy cluster join --cluster-node-name <Replica2 name> <Leader IP>