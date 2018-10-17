The Uninstall Workflow
======================

**Workflow name:** **``uninstall``**

**Workflow description:** Workflow for uninstalling applications.

**Workflow parameters:**

-  ``ignore_failure``: If ``true``, then operation errors encountered
   during uninstallation will not prevent the workflow from moving on;
   errors will be logged and printed. If ``false``, errors encountered
   during uninstallation will prompt the orchestrator to behave
   similarly to ``install`` (that is: retrying recoverable errors,
   aboring on non-recoverable errors).

**Workflow high-level pseudo-code:**

For each node, for each node instance (in parallel):

1. Wait for dependent node instances to be deleted. (Only start
   processing this node instance when the node instances dependent on it
   are deleted).

2. Execute ``cloudify.interfaces.monitoring.stop`` operation. [1]_

3. If node instance is host node (its type is a subtype of
   ``cloudify.nodes.Compute``):

   -  Execute ``cloudify.interfaces.monitoring_agent`` interface
      ``stop`` and ``uninstall`` operations. [1]_
   -  Stop and uninstall agent workers.


4. Execute ``cloudify.interfaces.lifecycle.stop`` operation. [1]_

5. Execute ``cloudify.interfaces.relationship_lifecycle.unlink``
   relationship operations. [2]_

6. Execute ``cloudify.interfaces.lifecycle.delete`` operation. [1]_

.. [1] Execute the task mapped to the node’s lifecycle operation (does nothing, if no task is defined).

.. [2] Execute all tasks mapped to this node’s relationship lifecycle operation (operations execute in the order defined by the node template relationships).