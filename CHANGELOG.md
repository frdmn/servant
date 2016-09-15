# servant changelog

## 0.1.2

- Turn integer and boolean values into strings in config.json
- Replace broken hostmanager with [custom fork](https://github.com/frdmn/servant/commit/61ff4ee32b32f28eddb7db8d1294f48697773ae3) 

## 0.1.1

- Fix config path in installation instructions
- Fix `stdin: is not a tty` warning while running shell provisioning
- Add change log

## 0.1.0

- Initial release
- Ubuntu 14.04 LTS
- Install Apache2, PHP-FPM, MySQL and phpMyAdmin
- Configuration file for general guest machine settings as well as MySQL and PHP versions (5.5 and 5.6)
- Multi project / virtual hosts support
- Support to "reload" the projects and configuration files (`vagrant provision`)
