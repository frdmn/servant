#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[Apache][${1}] /"
    else
        sed -e "s/^/[Apache] /"
    fi
}

# Add apt PPA for latest stable Apache
# (Required to remove conflicts with PHP PPA due to partial Apache upgrade within it)
sudo add-apt-repository -y ppa:ondrej/apache2 2>&1 | prefix "PPA"

# Update repositories
sudo apt-get update | prefix "APT update"

# Install Apache2
sudo apt-get install -y apache2 2>&1 | prefix "APT install"

# Add vagrant user to www-data group
sudo usermod -a -G www-data vagrant | prefix "config"

# Enable modules
sudo a2enmod rewrite actions ssl proxy_fcgi | prefix "config"

# Disable default virtual hosts if they exist
[[ -f "/etc/apache2/sites-available/000-default.conf" ]] && sudo rm /etc/apache2/sites-available/000-default.conf | prefix "config" && sudo a2dissite 000-default.conf | prefix "config"
[[ -f "/etc/apache2/sites-available/default-ssl.conf" ]] && sudo rm /etc/apache2/sites-available/default-ssl.conf | prefix "config"

# Symlink NFS share as document root
sudo rm -rf /var/www/html
sudo ln -sf /vagrant/public /var/www/html

# Write new default virtual host
sudo bash -c "cat > /etc/apache2/sites-available/00-webserver.dev.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName webserver.dev

    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/webserver.dev_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/webserver.dev_error.log
</VirtualHost>
EOAPACHE

# Create new Apache configuration file for PHP
sudo bash -c "cat > /etc/apache2/conf-available/php.conf" <<EOAPACHE
<FilesMatch ".+\.ph(p[345]?|t|tml)$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
EOAPACHE

sudo bash -c "cat > /etc/apache2/sites-available/00-phpinfo.dev.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName phpinfo.dev

    DocumentRoot /var/www/phpinfo

    <Directory /var/www/phpinfo>
        Options +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/phpinfo.dev_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/phpinfo.dev_error.log
</VirtualHost>
EOAPACHE

sudo mkdir -p /var/www/phpinfo
sudo bash -c "cat > /var/www/phpinfo/index.php" <<EOPHPINFO
<?php
    phpinfo();
EOPHPINFO

# Set default ServerName
sudo echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf

# Enable configs and restart web server
sudo a2enconf php.conf servername.conf | prefix "config"
sudo a2ensite 00-phpinfo.dev.conf 00-webserver.dev.conf | prefix "config"

# Restart Apache
sudo service apache2 restart | prefix "service"
