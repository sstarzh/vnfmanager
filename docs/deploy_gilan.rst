Part II. Deploy local F5 Gilan blueprint and create traffic server VM
=====================================================================

1. :ref:`Deploy Gilan blueprint <gilan>`
2. :ref:`Stand up traffic server VM <servervm>`
3. :ref:`Add static route <statroute>`
4. :ref:`Run test traffic <test>`

.. _gilan:

Step 1. Deploy Gilan blueprint
------------------------------

Once you change all the values in the Gi LAN inputs file and save it locally, upload the file in F5 VNF Manager. It will
define all required parameters for the F5 Gilan yaml blueprint.

1.	Open F5 VNFM, click :guilabel:`Local Blueprints`. The :guilabel:`gilan.yaml` main blueprint file appears.

2.  Click :guilabel:`Deploy`.

3.	Enter a name, under :guilabel:`Deployment Inputs`, click |clip_deploy| browse for the :guilabel:`gi_inputs.yaml` file you edited, and then click :guilabel:`Open`. The Deploy blueprint form is completed automatically with the values you entered in the gilan_inputs.yaml file.

4.	Click :guilabel:`Deploy`, on the left-side menu click the :guilabel:`Deployments` blade, in the list next to blueprint you created in the preivous step, expand |menuIcon_deploy|, click :guilabel:`Gilan install`, and then click :guilabel:`Execute`. VNFM starts creating BIG-IP VEs according to the parameters you defined for your network. Also installed includes additional, sub-blueprints packaged with the F5 gilan blueprint.

.. image:: images/gilan_install.png

6.	Once your blueprint install finishes executing, to view a model of your VNF installation, on the :guilabel:`Deployments` blade, click a **name** from the list. A model of your VNF topology appears, along with a list of all the nodes, and event logs.

7.	To view the list of Gilan workflows (for example, scale out group, deregister VE, etc.) that you can run, on the :guilabel:`Deployments` blade, click |menuIcon_deploy| next to your Gilan deployment in the list. A list of applicable workflows for your solution appears. Learn more about :doc:`workflows <use>`.

.. image:: images/run_wf.png

8.	To view the multiple BIP-IP VEs created by installing your F5 Gilan blueprint, open your OpenStack project and navigate to :menuselection:`Compute -> Instances`.

.. image:: images/os_instances.png

.. |menuIcon_deploy| image:: images/menuIcon.png

.. note:: Deployment will take 35-40 minutes to complete. Monitor the process by viewing :guilabel:`Deployments` screen until all nodes are **green**

.. image:: images/wf_complete.png

.. |clip_deploy| image:: images/clip.png


.. _servervm:

Step 2. Stand up traffic server VM
----------------------------------

1.  |srvInst_deploy|, and then define the following parameters, clicking :guilabel:`Next` to complete the wizard.

:menuselection:`Compute -> Instance`

============================================================ ======================================================================================================================================================================================================================================================================
Component                                                    Description
============================================================ ======================================================================================================================================================================================================================================================================
|source_deploy|                                              Expand :guilabel:`Select Boot Source`, and choose :guilabel:`Image`, under :guilabel:`Create New Volume`, click :guilabel:`No`, and then click :guilabel:`+` next to the `lamp-server-turnkey-15.0-stretch` image file to move it to the :guilabel:`Allocated` list.
                                                             
                                                             .. image:: images/server.png

|flavors_deploy|                                             Select :guilabel:`small` flavor

                                                             -  vCPU: 1
                                                             -  RAM: 2GB
                                                             -  Root disk: 20GB

|networks_deploy|                                            Select :guilabel:`+` next to the following predefined network (and subnet), to add to the :guilabel:`Allocated` list:

                                                             -  :guilabel:`PDN DAG Network (pdn_dag_net)` – Traffic Server will only communicate with BIG-IP FW instance.

|sg_deploy|                                                  Select :guilabel:`+` next to the following, predefined security group to add to the :guilabel:`Allocated` list:

                                                             -  Select Default security group :guilabel:`default`

|kp_deploy|                                                  Select existing `jumphost.pem` key pair for accessing VNFM instance remotely from jumphost, using SSH.
============================================================ ======================================================================================================================================================================================================================================================================

2.	For all other Instance component definitions, use the default values provided by OpenStack. For details, see |OSLnchIn_deploy|.


.. _statroute:

Step 3. Add static route to Openstack router
--------------------------------------------

1. Note DAG layer BIG-IP `pgw_net`  

2. Select :guilabel:`Network` --> :guilabel:`Routers` and click on :guilabel:`router1`
    Open :guilabel:`Static Routes` tab and click on :guilabel:`Add Static Route`
    Add the following route: 
    `<Server VM IP>/32` Next Hop `<DAG layer BIG-IP pgw_net IP>`

    .. image:: images/static.png



.. _test:

Step 4. Run test traffic to validate connectivity
-------------------------------------------------

1. SSH to UDF `traffic_gen` VM and run Apache Bench command

    .. code-block:: console

        sudo ab -n 10 -c 1 -b 1400 -B eth1 http://<Server IP>/

2. Output should contain statisticcal information on average RTT and # of bytes sent/received, among other data. Ensure Apache Bench received data back from the server.

    .. image:: images/ab_output.png


.. |source_deploy| raw:: html

    <a href="https://docs.openstack.org/horizon/rocky/user/launch-instances.html" target="_blank">Source</a>

.. |flavors_deploy| raw:: html

    <a href="https://docs.openstack.org/horizon/rocky/admin/manage-flavors.html" target="_blank">Flavors</a>

.. |networks_deploy| raw:: html

    <a href="https://docs.openstack.org/horizon/rocky/user/create-networks.html" target="_blank">Networks</a>

.. |sg_deploy| raw:: html

    <a href="https://docs.openstack.org/horizon/rocky/user/configure-access-and-security-for-instances.html" target="_blank">Security Groups</a>

.. |kp_deploy| raw:: html

    <a href="https://docs.openstack.org/horizon/rocky/user/configure-access-and-security-for-instances.html#keypair-add" target="_blank">Key Pair</a>

.. |srvInst_deploy| raw:: html

    <a href="https://docs.openstack.org/horizon/rocky/user/launch-instances.html" target="_blank">create and name a Traffic Server instance</a>


What’s Next?

:doc:`Trigger Auto-scaleout <auto_scaleout>`