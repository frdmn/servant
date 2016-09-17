.. _configuration:

Configuration file
==================

To provide some basic customization, you can edit your user config file ``~/.servant.json``. A sample configuration file is available in the source repository as ``config.json``.

**Caution**: If you change the configuration and want to apply the changes you need to destroy and recreat the **servant** machine up from scratch. This means you loose your SQL databases so make sure to dump them before!

general.source_uri
~~~~~~~~~~~~~~~~~~

The directory where the folder ``formulae/`` is located. This setting is for possible future use of loading remote formulae instead of local ones.

:Default value: ``.``

server.ip
~~~~~~~~~

IP address the virtual machine should use. Make sure to use a not existing subnet (eg. 192.168.1.10) to avoid IP collisions.

:Default value: ``192.168.50.10``

server.cpus
~~~~~~~~~~~

The amount of CPU cores the machine should use.

:Default value: ``1``

server.memory
~~~~~~~~~~~~~

And the allocated memory in MB.

:Default value: ``1024``

server.swap
~~~~~~~~~~~

If you want to use swap, you can use this setting. Represents MB if not ``false``.

:Possible values: ``false`` or ``512``
:Default value: ``false``

server.timezone
~~~~~~~~~~~~~~~

The timezone PHP and the OS should use. For a list of possible timezones, `click here <http://php.net/manual/en/timezones.php>`_.

:Default value: ``Europe/Berlin``

mysql.root_password
~~~~~~~~~~~~~~~~~~~

The MySQL root password.

:Default value: ``root``

mysql.version
~~~~~~~~~~~~~

MySQL server version to install and use.

:Possible value: ``5.6`` or ``5.5``
:Default value: ``5.6``

php.version
~~~~~~~~~~~

PHP server version to install and use.

:Possible value: ``5.6`` or ``5.5``
:Default value: ``5.6``
