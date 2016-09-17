#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[vhost][-][${1}] /"
    else
        sed -e "s/^/[vhost][-] /"
    fi
}

# Store arguments and variables
args_root_password="${1}"

###
# Initial bootstrap
###

if [[ ! -f /opt/servant/formulae/vhosts.lockfile ]]; then
    # none

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant/formulae/vhosts.lockfile
fi

###
# Recurring bootstrap
###

# Check if lockfile folder is not empty
if [[ ! -z $(find /opt/servant/vhosts/ -maxdepth 1 -type f) ]]; then
    # Check if there are stale vhosts
    for lockfile in /opt/servant/vhosts/*; do
         # Load substituted database/password name
        virtual_hostname=$(basename "${lockfile}")
        virtual_db_hostname=$(cat "/opt/servant/mysql/${virtual_hostname}")

        # Check if directroy still exists in public/ folder
        if [[ ! -d "/var/www/html/${virtual_hostname}" ]]; then
            # Disable and remove virtual host
            sudo a2dissite ${virtual_hostname}.conf | prefix "${virtual_hostname}][Apache"
            rm /etc/apache2/sites-available/${virtual_hostname}.conf

            # Drop database and SQL user
            MYSQL_PWD=${args_root_password} mysql -u root -e """
            DROP DATABASE \`${virtual_db_hostname}\`;
            DROP USER \`${virtual_db_hostname}\`@'localhost';
            """

            # Make sure to restart Apache at the end of the script
            touch /opt/servant/apache.restart

            # Remove lockfile
            rm ${lockfile}

            echo "Removed user and database \"${virtual_db_hostname}\"" | prefix "${virtual_hostname}][MySQL"
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
