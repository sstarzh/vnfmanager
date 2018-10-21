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


1. Point Jumphost Browser to a `master` VNF(FW) BIG-IP instance .40 IP address and login to BIG-IP TMUI
    a. Navigate to :guilabel:`Statistics` --> :guilabel:`Analytics` --> :guilabel:`CPU`
    b. Watch CPU graph as it crosses 15% CPU threshold
2. Point your browser to the public floating `10.1.20.x` IP address of VNF Manager VM
    a. Login to VNF manager UI and click on :guilabel:`Deployments` from the left-side menuIcon
    b. Watch as VNF manager performs auto scale-out of VNF(FW) instances
3. SSH to Nagios VM from jumphost using jumphost.pem key and watch nagios log file:

    .. code_block:: console
    ssh -i ~/Downloads/jumphost.pem centos@10.1.20.XXX
    sudo -i
    less /var/log/nagios/nagios.log


.. |menuIcon_use| image:: images/menuIcon.png



What’s Next?

:doc:`Initiate Manual scaleout <man_scaleout>`