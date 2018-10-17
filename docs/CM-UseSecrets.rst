
Use the Secret Store
====================

The secrets store provides a secured variable storage (key-value pairs)
for data that you do not want to expose in plain text in F5 VNFM
blueprints, such as login credentials for a platform. The values of the
secrets are encrypted in the database. We use the Fernet encryption of
cryptography library, which is a symmetric encryption method that makes
sure that the message encrypted cannot be manipulated/read without the
key. When you create a secret, the key value can be a text string or it
can be a file that contains the key value. The secret store lets you
make sure all secrets (for example credentials to IaaS environments) are
stored separately from blueprints, and that the secrets adhere to
isolation requirements between different tenants. You can include the
secret key in your blueprints and not include the actual values in the
blueprints. For more information, see the get_secret_ intrinsic function.



Secrets with a hidden value
```````````````````````````

All the values of the secrets are encrypted in the database. When you
create a secret you can specify if you want its value to be hidden or
not. A secret with a hidden value means the value is only shown to the
user who created it, tenant managers and sys-admins. Users can use the
secret according to the user roles and the visibility of the secret.

Updating a secret
-----------------

Updating a secret with a shown value
````````````````````````````````````

-  Updating the secret’s value and visibility or deleting the secret is
   allowed according to the user roles and the visibility of the secret.
-  Updating the secret to hide the value is only allowed to the user who
   created it, tenant managers and sys-admins.

Updating a secret with a hidden value
`````````````````````````````````````

Only the creator of the secret, a sys-admin or a tenant manager of the
tenant the secret is stored on can see, update or delete the secret with
a hidden value (unlike a secret with a shown value which other users in
the tenant can also update or delete).

Creating a secret from the CLI
------------------------------

You can use the ``cfy secrets`` command to manage VNFM secrets
(key-value pairs).

.. code-block:: console

   $ cfy secrets create test -s test_value …

   Secret ``test`` created

   …

For more commands, see Secrets commands.

Creating a secret from the F5 VNFM Console
-------------------------------------------

Secret Store Management is performed from the System Resources page in
the VNFM Console.

1. Click :guilabel:`Create` in the Secret Store Management widget.
2. Insert the following values:

   -  The secret key
   -  The secret value (or select the secret file from your file
      repository)
   -  The visibility level (the icon of the green man)
   -  If the value of the secret should be hidden

3. Click :guilabel:`Create`.

   .. figure:: /images/create_secret_dialog.png
      :alt: Create Secret

4. Press on the eye icon for viewing the secret value.
5. To change the visibility level of the secret, click on the visibility
   icon in the key cell.
6. To hide the secret value, select the Hidden checkbox.
7. For updating the secret value there is an edit icon in the right and
   next to it the delete icon.

.. figure:: /images/secret_management.png
   :alt: View Secret

.. _get_secret:

get_secret
----------

``get_secret`` is used for referencing ``secrets`` described in the
:doc:`Secrets <CM-REST-API>` API. ``get_secret``
can be used in node properties, outputs, node/relationship operation
inputs, and runtime-properties of node instances. The function is
evaluated at runtime.

**Example**

.. code-block:: yaml

   node_templates: host: type: cloudify.nodes.Compute properties: ip: {
   get_secret: ip } cloudify_agent: key: { get_secret: agent_key } user: {
   get_secret: user } interfaces: test_interface: test_operation:
   implementation: central_deployment_agent inputs: operation_input: {
   get_secret: operation_input }

   outputs:

   webserver_url: description: Web server url value: { concat: [‘http://’,
   { get_secret: ip }, ‘:’, { get_secret: webserver_port }] }


In this example, get_secret is used for completing several of the host
node’s properties, as well as an operation input. In addition, it is
used twice in the concatenated ``webserver_url`` output.