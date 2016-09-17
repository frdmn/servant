.. _general:

General
=======

Vagrant commands expects to be executed from within the directory where the ``Vagrantfile`` is located. Make sure to change into the directory where you've cloned **servant** to, when running the commands below.

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
