Usage
=====

Create and bootstrap virtual machine initally
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. To initially create the **servant** machine, just run: ::

    cd ~/servant
    vagrant up

Add a new virtual host / web project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following steps explain how to add new virtual hosts or web projects in the Apache configuration and setup MySQL databases:

1. Create a new directory in the `public/` folder, which is using the hostname of your choice as foldername: ::

    cd ~/servant/public
    mkdir demoproject.io

    # Some test code to see if PHP works properly
    echo "<?php echo 'test';" > demoproject.io/index.php

2. Run the Vagrant command, so **servant** can setup your Apache configurations and create your database as well as adjust your `/etc/hosts` file on your Mac: ::

    vagrant provision
