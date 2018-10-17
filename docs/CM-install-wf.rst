The Install Workflow
====================

**Workflow name:** **``install``**

**Workflow description:** Workflow for installing applications.

**Workflow high-level pseudo-code:**

For each node, for each node instance (in parallel):

1. Wait for node instance relationships to be started. (Only start
   processing this node instance when the node instances it depends on
   are started).

2. Execute ``cloudify.interfaces.lifecycle.create`` operation. [1]_

3. Execute ``cloudify.interfaces.relationship_lifecycle.preconfigure``
   relationship operations. [2]_

4. Execute ``cloudify.interfaces.lifecycle.configure`` operation. [1]_

5. Execute ``cloudify.interfaces.relationship_lifecycle.postconfigure``
   relationship operations. [2]_

6. Execute ``cloudify.interfaces.lifecycle.start`` operation. [1]_

7. If the node instance is a host node (its type is a subtype of
   ``cloudify.nodes.Compute``):

   -  Install agent workers and required plugins on this host.
   -  Execute ``cloudify.interfaces.monitoring_agent`` interface
      ``install`` and ``start`` operations. [1]_


8. Execute ``cloudify.interfaces.monitoring.start`` operation. [1]_

9. Execute ``cloudify.interfaces.relationship_lifecycle.establish``
   relationship operations. [2]_

.. [1] Execute the task mapped to the node’s lifecycle operation. (do nothing if no task is defined).

.. [2] Execute all tasks mapped to this node’s relationship lifecycle operation. (Operations are executed in the order defined by the node template relationships)