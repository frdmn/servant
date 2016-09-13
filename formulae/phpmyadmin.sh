#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[PMA][${1}] /"
    else
        sed -e "s/^/[PMA] /"
    fi
}

# Store arguments and variables
args_root_password="${1}"
random_hash="$(date | md5sum | cut -f 1 -d " ")"

# Download and extract latest version
wget -O- https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz | sudo tar xvz -C /var/www/ 2>&1 | prefix "Source"
sudo mv /var/www/phpMyAdmin-*-all-languages /var/www/phpmyadmin

# Create new Apache configuration file
sudo bash -c "cat > /etc/apache2/conf-available/phpmyadmin.conf" <<EOAPACHE
Alias /phpmyadmin/ "/var/www/phpmyadmin/"
<Directory "/var/www/phpmyadmin/">
    Order allow,deny
    Allow from all
    Require all granted
</Directory>
EOAPACHE

# Enable config and restart server
sudo a2enconf phpmyadmin.conf | prefix "config"
sudo service apache2 restart | prefix "service"

# Create phpmyadmin storage database
cat /var/www/phpmyadmin/sql/create_tables.sql | mysql -u root -p${args_root_password} 2>&1 | prefix "storage"
echo "GRANT SELECT, INSERT, DELETE, UPDATE ON phpmyadmin.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY \"phpmyadmin\"" | mysql -u root -p${args_root_password} 2>&1 | prefix "storage"

# Adjust default configuration
cat > /var/www/phpmyadmin/config.inc.php <<EOCONFIG
<?php
    \$cfg['blowfish_secret'] = '${random_hash}';

    \$i = 0;
    \$i++;

    \$cfg['Servers'][\$i]['auth_type'] = 'cookie';
    \$cfg['Servers'][\$i]['host'] = 'localhost';
    \$cfg['Servers'][\$i]['connect_type'] = 'tcp';
    \$cfg['Servers'][\$i]['compress'] = false;
    \$cfg['Servers'][\$i]['AllowNoPassword'] = false;
    \$cfg['Servers'][\$i]['controluser'] = 'phpmyadmin';
    \$cfg['Servers'][\$i]['controlpass'] = 'phpmyadmin';

    \$cfg['UploadDir'] = '';
    \$cfg['SaveDir'] = '';
EOCONFIG
