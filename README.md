| :construction: This project is a *work in progress* :construction: |
|---|

# servant

[![asciicast](https://asciinema.org/a/85841.png)](https://asciinema.org/a/85841)

**Servant** is a custom Vagrant virtual machine which offers a straightforward and easy to use web-development system based on services like [Apache](https://httpd.apache.org/), [PHP (FPM)](http://php-fpm.org/), [MySQL](https://www.mysql.com/) and [phpMyAdmin](https://www.phpmyadmin.net/), but isolated from your host system. Primary goal is to provide a consistent dev environment for developers or employees in a small company/startup.

## Installation

1. Make sure you've installed all requirements
2. Clone this repository:

    ```shell
    cd
    git clone https://github.com/frdmn/servant
    ```

3. Copy the sample configuration file into your `$HOME`:

    ```shell
    cp servant/config.json ~/.servant.json
    ```

Follow the Usage instructions how to correctly setup new projects.
    
## Usage

### Create and bootstrap virtual machine initally

1. To initially create the **servant** machine, just run:

    ```shell
    cd ~/servant
    vagrant up
    ```

### Add a new virtual host / web project

The following steps explain how to add new virtual hosts or web projects in the Apache configuration and setup MySQL databases:

1. Create a new directory in the `public/` folder, which is using the hostname of your choice as foldername:

    ```shell
    cd ~/servant/public
    mkdir demoproject.io
    echo "<?php echo 'test';" > demoproject.io/index.php
    ```

2. Run the Vagrant command, so **servant** can setup your Apache configurations and create your database as well as adjust your `/etc/hosts` file on your Mac:

    ```shell
    vagrant provision
    ```

## Contributing

1. Fork it
2. Create your feature branch:

    ```shell
    git checkout -b feature/my-new-feature
    ```

3. Commit your changes:

    ```shell
    git commit -am 'Add some feature'
    ```

4. Push to the branch:

    ```shell
    git push origin feature/my-new-feature
    ```

5. Submit a pull request

## Requirements / Dependencies

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)
    - [`vagrant-bindfs`](https://github.com/gael-ian/vagrant-bindfs) plugin
    - [`vagrant-hostmanager`](https://github.com/devopsgroup-io/vagrant-hostmanager) plugin

## Credits

- [fideloper](https://github.com/fideloper), for the idea to bootstrap Vagrant using Shell provisioners

## Version

0.1.0

## License

[MIT](LICENSE)
