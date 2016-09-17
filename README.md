| :construction: This project is a *work in progress* :construction: |
|---|

# servant

[![asciicast](https://asciinema.org/a/85841.png)](https://asciinema.org/a/85841)

**Servant** is a custom Vagrant virtual machine which offers a straightforward and easy to use web-development system based on services like [Apache](https://httpd.apache.org/), [PHP (FPM)](http://php-fpm.org/), [MySQL](https://www.mysql.com/) and [phpMyAdmin](https://www.phpmyadmin.net/), but isolated from your host system. Primary goal is to provide a consistent dev environment for developers or employees of a small company/startup. 

## Features

- Isolated from OS X host system (OS updates won't affect the dev services, ever)
- Performant (PHP-FPM and OPcache module enabled)
- Easily add and remove projects (virtual hosts), **servant** automatically creates the necessary web server configurations as well as a MySQL database
- Automatically write/update `/etc/hosts` file on your Mac
- Supports PHP 5.6 and alternatively 5.5 
- Supports MySQL 5.6 and alternatively 5.5 

## Installation and usage

Please take a look at the documentation over at http://servant.rtfd.io.

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
    - [`vagrant-hosts-provisioner`](https://github.com/frdmn/vagrant-hosts-provisioner) plugin (custom fork)
    - [`vagrant-triggers`](https://github.com/emyl/vagrant-triggers) plugin

## Credits

- [fideloper](https://github.com/fideloper), for the idea to bootstrap Vagrant using Shell provisioners

## Version

0.1.5

## License

[MIT](LICENSE)
