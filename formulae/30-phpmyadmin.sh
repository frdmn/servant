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
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O /tmp/source.zip 2>&1 | prefix "source"
sudo unzip /tmp/source.zip -d /var/www/ 2>&1 | prefix "source"
sudo mv /var/www/phpMyAdmin-*-all-languages /var/www/phpmyadmin

# Write new default virtual host
sudo bash -c "cat > /etc/apache2/sites-available/00-phpmyadmin.dev.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName phpmyadmin.dev

    DocumentRoot /var/www/phpmyadmin

    <Directory "/var/www/phpmyadmin/">
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/phpmyadmin.dev_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/phpmyadmin.dev_error.log
</VirtualHost>
EOAPACHE

# Enable config and restart server
sudo a2ensite 00-phpmyadmin.dev | prefix "config"
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
