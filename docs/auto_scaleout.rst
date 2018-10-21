Part III. Trigger auto scale-out
================================

1. :ref:`Run Apache Bench <traffic_run>`
2. :ref:`Watch BIG-IP statistics and VNF manager actions <watch>`


.. _traffic_run:

Step 1. Run Apache Bench from traffic_gen VM
--------------------------------------------

1. SSH to `traffic_gen` VM and run `run_traffic.sh` script passing Server IP as an argument:

    .. code-block:: console

        ./run_traffic.sh 10.1.52.XX

2. Log files are generated for each thread and are located in the same directory (ab[1-10].out)


.. _watch:

Step 2. Watch BIG-IP statistics and scaleout process in VNF manager
-------------------------------------------------------------------

1. Point jumphost browser to .40 IP of FW BIG-IP (master) and login as `admin`
2. 





.. |menuIcon_use| image:: images/menuIcon.png



What’s Next?

:doc:`Initiate Manual scaleout <man_scaleout>`