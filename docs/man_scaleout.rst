Part IV. Initiate manual scale-out
==================================


VNF Manager can scale-out/in both DAG and Firewall layers. THis lab focuses on manual scale-out procedure for scaling out DAG layer.

To manually scale-out DAG layer, select :guilabel:`Deployments` --> :guilabel:`dag_group_xxx` Blueprint 
Expand |menuIcon_deploy|, click :guilabel:`Gilan scale out group`. Keep `add_instances` value of `1`, and then click :guilabel:`Execute`.

.. image:: images/man_scaleout.png

.. |menuIcon_deploy| image:: images/menuIcon.png


For more information about Scale Workflow see:
:doc:`The Scale Workflow <CM-scale-wf>`