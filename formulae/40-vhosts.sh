#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[vhost][${1}] /"
    else
        sed -e "s/^/[vhost] /"
    fi
}

# For each custom virtual host
for directory in /var/www/html/*; do
    virtual_hostname=$(basename ${directory})
    sudo bash -c "cat > /etc/apache2/sites-available/${virtual_hostname}.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName ${virtual_hostname}

    DocumentRoot /var/www/html/${virtual_hostname}

    <Directory /var/www/html/${virtual_hostname}>
        Options +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/${virtual_hostname}_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/${virtual_hostname}_error.log
</VirtualHost>
EOAPACHE

    sudo a2ensite ${virtual_hostname}.conf | prefix "${virtual_hostname}"
done

# Restart Apache
sudo service apache2 restart | prefix "service"
