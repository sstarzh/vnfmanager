The Scale Workflow
==================

**Workflow name:** **``scale``**

**Workflow description:**

Scales out/in the node subgraph of the system topology applying the
``install``/``uninstall`` workflows’ logic respectively.

If the entity denoted by ``scalable_entity_name`` is a node template
that is contained in a compute node (or is a compute node itself) and
``scale_compute`` is ``true``, the node graph will consist of all nodes
that are contained in the compute node which contains
``scalable_entity_name`` and the compute node itself. Otherwise, the
subgraph will consist of all nodes that are contained in the
node/scaling group denoted by ``scalable_entity_name``.

In addition, nodes that are connected to nodes that are part of the
contained subgraph will have their ``establish`` relationship operations
executed during scale out and their ``unlink`` relationship operations
executed during scale in.

**Workflow parameters:**

-  **``scalable_entity_name``**: The name of the node/scaling group to
   apply the scaling logic to.
-  **``delta``**: The scale factor. (Default: ``1``)

   -  For ``delta > 0``: If the current number of instances is ``N``,
      scale out to ``N + delta``.
   -  For ``delta < 0``: If the current number of instances is ``N``,
      scale in to ``N - |delta|``.
   -  For ``delta == 0``, leave things as they are.

-  ``scale_compute``: should ``scale`` apply on the compute node
   containing the node denoted by ``scalable_entity_name`` (default value is ``false``).

   -  If ``scalable_entity_name`` specifies a node, and
      ``scale_compute`` is set to ``false``, the subgraph will consist
      of all the nodes that are contained in the that node and the node
      itself.
   -  If ``scalable_entity_name`` specifies a node, and
      ``scale_compute`` is set to ``true``, the subgraph will consist of
      all nodes that are contained in the compute node that contains the
      node denoted by ``scalable_entity_name`` and the compute node
      itself.
   -  If the node denoted by ``scalable_entity_name`` is not contained
      in a compute node or it specifies a group name, this parameter is
      ignored.

**Workflow high-level pseudo-code:**

1. Retrieve the scaled node/scaling group, based on
   ``scalable_entity_name`` and ``scale_compute`` parameters.
2. Start deployment modification, adding or removing node instances and
   relationship instances.
3. If ``delta > 0``:

   -  Execute install lifecycle operations (``create``, ``configure``,
      ``start``) on added node instances.
   -  Execute the ``establish`` relationship lifecycle operation for all
      affected relationships.

4. If ``delta < 0``:

   -  Execute the ``unlink`` relationship lifecycle operation for all
      affected relationships.
   -  Execute uninstall lifecycle operations (``stop``, ``delete``) on
      removed node instances.

**NOTE**: Detailed description of the terms *graph* and
*sub-graph* that are used in this section, can be found in the :doc:`Heal <CM-heal-wf>`
workflow section.