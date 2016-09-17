#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[vhost][+][${1}] /"
    else
        sed -e "s/^/[vhost][+] /"
    fi
}

function print_apache_vhost { cat <<EOF
<VirtualHost *:80>
    ServerName ${virtual_hostname}

    DocumentRoot /var/www/html/${virtual_hostname}/htdocs

    <Directory /var/www/html/${virtual_hostname}/htdocs>
        Options +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    CustomLog /var/www/html/${virtual_hostname}/logs/access.log combined
    ErrorLog /var/www/html/${virtual_hostname}/logs/error.log
</VirtualHost>
EOF
}

# Store arguments and variables
args_root_password="${1}"

###
# Initial bootstrap
###

if [[ ! -f /opt/servant/formulae/vhosts_add-new.lockfile ]]; then
    # none

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant/formulae/vhosts_add-new.lockfile
fi

###
# Recurring bootstrap
###

# If there are any vhosts in public/
if [[ ! -z $(find /var/www/html/ -maxdepth 1 -type d ! -path /var/www/html/) ]]; then
    # For each custom virtual host
    for directory in /var/www/html/*; do
        # Store hostname in variable and substitute dots with dashes for MySQL
        virtual_hostname=$(basename "${directory}")
        virtual_db_hostname=${virtual_hostname/./_}
        virtual_db_hostname=${virtual_db_hostname:0:16}

        # Check if vhost was already created, if not create
        if [[ ! -f "/opt/servant/vhosts/${virtual_hostname}" ]]; then
            # Create necessary folders
            sudo mkdir -p ${directory}/{htdocs,logs}

            # write configuration file
            sudo bash -c "cat > /etc/apache2/sites-available/${virtual_hostname}.conf" <<< "$(print_apache_vhost)"

            # Enable config
            sudo a2ensite ${virtual_hostname}.conf | prefix "${virtual_hostname}][Apache"

            # Create MySQL database and user
            MYSQL_PWD=${args_root_password} mysql -u root -e """
            CREATE DATABASE IF NOT EXISTS \`${virtual_db_hostname}\` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;
            GRANT ALL ON \`${virtual_db_hostname}\`.* TO \`${virtual_db_hostname}\`@'localhost' IDENTIFIED BY '${virtual_db_hostname}';
            """

            # Store lockfile / password for the database
            printf "${virtual_db_hostname}" > /opt/servant/mysql/${virtual_hostname}

            # Make sure to restart Apache at the end of the script
            touch /opt/servant/apache.restart

            # Create lockfile
            touch /opt/servant/vhosts/${virtual_hostname}

            echo "Created user and database \"${virtual_db_hostname}\"" | prefix "${virtual_hostname}][MySQL"
        fi
    done
fi

# Restart Apache if necessary
if [[ -f /opt/servant/apache.restart ]]; then
    sudo service apache2 restart | prefix "service"
    rm /opt/servant/apache.restart
fi

# Exit without errors
exit 0
