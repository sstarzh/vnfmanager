Part V. Initiate manual scale-out
=================================

1. :ref:`Execute scale-out workflow <scaleout>`
2. :ref:`Modify Openstack route to new DAG instance <newdag>`
3. :ref:`Run test traffic <test_dag>`

.. _scaleout:

Step 1. Execute Scale-out workflow
----------------------------------

VNF Manager can scale-out/in both DAG and Firewall layers. THis lab focuses on manual scale-out procedure for scaling out DAG layer.

To manually scale-out DAG layer, select :guilabel:`Deployments` --> :guilabel:`dag_group_xxx` Blueprint 
Expand |menuIcon_deploy|, click :guilabel:`Gilan scale out group`. Keep `add_instances` value of `1`, and then click :guilabel:`Execute`.

.. image:: images/man_scaleout.png

.. |menuIcon_deploy| image:: images/menuIcon.png


.. _newdag:

Step 2. Modify openstack route
------------------------------

1. Note newly created DAG layer BIG-IP `pgw_net`  

2. Select :guilabel:`Project` --> :guilabel:`Network` --> :guilabel:`Routers` and click on :guilabel:`router1`
    Open :guilabel:`Static Routes` tab and click on :guilabel:`Delete Static Route` to delete previously provisioned route.
    Click on :guilabel:`Add Static Route`
    Add the following route: 
    `10.1.52.101/32` Next Hop `<DAG layer BIG-IP pgw_net IP>`

    .. image:: images/static2.png

.. _test_dag:

Step 3. Run test traffic
------------------------

1. Run test traffic through new DAG instance

:ref:`Run test traffic <test>`

.. note:: This test is the same as in Part III Step 3 of this lab guide


2. Point Jumphost Browser to new DAG BIG-IP instance .40 IP address and login to BIG-IP TMUI
3. Navigate to :guilabel:`Local Traffic` --> :guilabel:`Virtual Servers`, then select `f5vnf` partition from :guilabel:`Partition:` menu
4. Select `firewall_fastL4` VS and click on :guilabel:`Statistics` menu

    Traffic statistics will be visible in `Traffic Details` and `Connections` parts of Statistics screen. Note that due to the asymmetric routing, return traffic is NOT passing through the same DAG instance


.. image:: images/module_stats.png

.. note:: Other methods may be used to validate that the traffic is flowing through new DAG instances including running a tcpdump



For more information about Scale Workflow see:
:doc:`The Scale Workflow <CM-scale-wf>`


What’s Next?

:doc:`Change AFM Configuration via AS3 <conf_change>`