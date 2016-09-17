.. _mysql:

MySQL databases
===============

When you setup a virtual hosts, the system also creates a MySQL database and user dedicated to that project. For simplicity's sake the database, username as well as the password represent (again) the hostname of your project. However, because of some naming restrictions within MySQL, dots (``.``) are replaced with underscores (``_``) and only the first 16 characters of the hostname is used. Some examples:

- If your project is using the hostname "testproject.io", the database, username and password will be ``testproject_io``
- If the hostname is "prettylonghostname.com", it'll be ``prettylonghostna``

System credentials
~~~~~~~~~~~~~~~~~~

The following credentials are created by default in every **servant** environment:

+------------+------------------------------------------+
| Username   | Password                                 |
+============+==========================================+
| root       | The password set in :ref:`configuration` |
+------------+------------------------------------------+
| phpmyadmin | ``phpmyadmin``                           |
+------------+------------------------------------------+

phpMyAdmin
~~~~~~~~~~

.. image:: _static/images/phpmyadmin.png
   :scale: 50%
   :target: http://phpmyadmin.dev

To manage your databases you can use the builtin phpMyAdmin: `<http://phpmyadmin.dev>`_
