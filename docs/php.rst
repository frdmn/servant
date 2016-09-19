.. _php:

PHP
===

To make sure your PHP applications run performant, **servant** is using `FPM <http://php-fpm.org/>`_ as handler and comes with enabled `OPcache module <http://php.net/manual/en/book.opcache.php>`_ to speed up your PHP processing.

Default settings
~~~~~~~~~~~~~~~~

When the virtual machine is booted for the first time, some of the PHP configurations are set as listed below:

+-------------------------------------+--------------------------------------------+
| Setting                             | Value                                      |
+=====================================+============================================+
| ``error_reporting``                 | ``root``                                   |
+-------------------------------------+--------------------------------------------+
| ``display_errors``                  | ``phpmyadmin``                             |
+-------------------------------------+--------------------------------------------+
| ``date.timezone``                   | The timezone set in :ref:`configuration`   |
+-------------------------------------+--------------------------------------------+
| ``xdebug.show_local_vars``          | ``1``                                      |
+-------------------------------------+--------------------------------------------+
| ``xdebug.var_display_max_depth``    | ``5``                                      |
+-------------------------------------+--------------------------------------------+
| ``xdebug.var_display_max_children`` | ``256``                                    |
+-------------------------------------+--------------------------------------------+
| ``xdebug.var_display_max_data``     | ``1024``                                   |
+-------------------------------------+--------------------------------------------+

``phpinfo()``
~~~~~~~~~~~~~

There's a built in phpinfo page if you are interested in the current loaded settings: `<http://phpinfo.dev>`_

Customizations
~~~~~~~~~~~~~~

Just like with the web server configuration, you can override the global PHP settings per virtual host in case you need a special PHP environment. Just create a ``.user.ini`` file inside your document root (``htdocs`` by default) and insert your custom configuration: ::

    always_populate_raw_post_data = -1
    memory_limit = 512M
