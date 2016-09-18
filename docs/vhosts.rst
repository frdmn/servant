.. _vhosts:

Virtual hosts
=============

You need to work on multiple projects simultanously? Not a problem, **servant** supports virtual hosts using a straightforward rule: Each directory in the ``public/`` folder represents the hostname of the project you want to work on. A single command creates the necessary configurations within the virtual machine, reloads the services and rewrites the ``/etc/hosts`` file on your Mac.

Access document root
~~~~~~~~~~~~~~~~~~~~

You can reach the root directory of the web server via `<http://servant.dev>`_

Create new virtual hosts
~~~~~~~~~~~~~~~~~~~~~~~~

1. Change into the **servant** directory: ::

    cd ~/servant

2. Create a new folder inside `public/` named exactly the same as the hostname of your project: ::

    mkdir public/testproject.io

3. Run the provision command to create the server configurations and update your ``/etc/hosts`` file locally: ::

    vagrant provision

Delete virtual hosts
~~~~~~~~~~~~~~~~~~~~

To remove a virtual host, simply delete the directory that represents the hostname of your project: ::

    rm -r public/testproject.io

Don't forget to reload **servant**: ::

    vagrant provision

Customizations
~~~~~~~~~~~~~~

You can override the default Apache web server configuration for your virtual host in case you need a custom DocumentRoot or an additonal ServerAlias. To do that you need to place a JSON configuration file named ``servant.json`` in your project root folder. Checkout the example below:: :

  {
    "document_root": "blog",
    "server_alias": "aliasdomain.com"
  }
