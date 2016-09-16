General
=======

Start/create virtual machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To initially create the **servant** machine, just run: ::

    vagrant up

Shutdown/end VM
~~~~~~~~~~~~~~~

To power off the virtual machine: ::

    vagrant suspend

Login via SSH
~~~~~~~~~~~~~

Vagrant provides a passwordless SSH login using: ::

    vagrant ssh

Reload **servant**
~~~~~~~~~~~~~~~~~~

::

    vagrant provision
