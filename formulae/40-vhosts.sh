#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[vhost][${1}] /"
    else
        sed -e "s/^/[vhost] /"
    fi
}

# Store arguments and variables
args_root_password="${1}"

# For each custom virtual host
for directory in /var/www/html/*; do
    # Store hostname in variable and substitute dots with dashes for MySQL
    virtual_hostname=$(basename ${directory})
    virtual_db_hostname=${virtual_hostname/./_}

    # write configuration file
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

    # Enable config
    sudo a2ensite ${virtual_hostname}.conf | prefix "${virtual_hostname}][Apache"

    # Create MySQL database and user

    MYSQL_PWD=${args_root_password} mysql -u root -e """
    CREATE DATABASE IF NOT EXISTS ${virtual_db_hostname} DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
    GRANT ALL ON ${virtual_db_hostname}.* TO '${virtual_db_hostname}'@'localhost' IDENTIFIED BY '${virtual_db_hostname}';
    """

    echo "Created user and database \"${virtual_db_hostname}\"" | prefix "${virtual_hostname}][MySQL"
done

# Restart Apache
sudo service apache2 restart | prefix "service"
