#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[Apache][${1}] /"
    else
        sed -e "s/^/[Apache] /"
    fi
}

# Store arguments in variables
args_hostname="${1}"

# Add apt PPA for latest FULL stable Apache
# (Required to remove conflicts with PHP PPA due to partial Apache upgrade within it)
sudo add-apt-repository -y ppa:ondrej/apache2 2>&1 | prefix "PPA"

# Update repositories
sudo apt-get update | prefix "APT update"

# Install Apache2
sudo apt-get install -y apache2 2>&1 | prefix "APT install"

# Add vagrant user to www-data group
sudo usermod -a -G www-data vagrant

# Enable modules
sudo a2enmod rewrite actions ssl proxy_fcgi

# Disable default virtual hosts
sudo a2dissite 000-default.conf
sudo rm /etc/apache2/sites-available/default-ssl.conf

# Write new default virtual host
sudo bash -c "cat > /etc/apache2/sites-available/web1.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName ${args_hostname}

    DocumentRoot /vagrant/public

    <Directory /vagrant/public>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted

        <FilesMatch ".+\.ph(p[345]?|t|tml)$">
            SetHandler "proxy:fcgi://127.0.0.1:9000"
        </FilesMatch>
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/${args_hostname}_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/${args_hostname}_error.log
</VirtualHost>
EOAPACHE

sudo a2ensite web1.conf

# Restart Apache
sudo service apache2 restart
