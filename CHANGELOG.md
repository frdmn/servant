# servant changelog

## 0.1.7

- Clean code / properly escape variables
- Add missing default modules for common web applications (Contao, Typo3, Magento, Wordpress)
- Add general PHP configuration parameters (`memory_limit`, `post_max_size`, `max_execution_timout`)
- Install composer in virtual machine ([#27](https://github.com/frdmn/servant/issues/27))
- Document how to add custom PHP settings per virtual host ([#28](https://github.com/frdmn/servant/issues/28))
- Remove unused `soure_uri` ([#30](https://github.com/frdmn/servant/issues/30))
- Move configuration into **servant** root folder ([#29](https://github.com/frdmn/servant/issues/29))
- Add Adminer as alternative to phpMyAdmin ([#12](https://github.com/frdmn/servant/issues/12))

## 0.1.6

- Hide `information_schema` databases in phpMyAdmin
- Add MySQL backup and import functionality ([#7](https://github.com/frdmn/servant/issues/7)) 
- Create emergency MySQL backups in case of Vagrant destroy 
- Allow virtual host customizations ([#13](https://github.com/frdmn/servant/issues/13))

## 0.1.5

- Add extended docs: http://servant.rtfd.io
- Cleanup comments
- Use `servant.dev` as default hostname
- Remove unused `host_port_http` option from config.json
- Add passwordless login to phpMyAdmin ([e2fa37f](https://github.com/frdmn/servant/commit/e2fa37fbd27dfa39201923b8a69e9cf9b99f6b89))
- Add htdocs/logs folder within projects document root ([436c42e](https://github.com/frdmn/servant/commit/436c42e9639861c10fc19776fdaef67342bf300a))

## 0.1.4

- Don't restart services in case no changed configurations
- Only apply apt updates in case of pending ones
- New provisioner plugin, once again - released via [RubyGems](https://rubygems.org/gems/vagrant-servant-hosts-provisioner)
- Separate virtual host formula
- Add missing check to prevent duplicate project creation
- Add OPcache PHP module

## 0.1.3

- Remove stale projects [#6](https://github.com/frdmn/servant/issues/6)
- Fix incorrect swap command construction

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
