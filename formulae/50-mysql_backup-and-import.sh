#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[SQL][${1}] /"
    else
        sed -e "s/^/[SQL] /"
    fi
}

# Function to create backup of certain MySQL user
function backup_all_databases {
    mysql_user="${1}"
    mysql_pass="${2}"
    backup_location="${3}"
    prefix="${4}"

    [[ -z ${prefix} ]] && prefix=$(date +%Y%m%d%H%M)

    # Get a list of available databases per user
    mysql_databases=$(MYSQL_PWD=${mysql_pass} mysql -u ${mysql_user} -e "SHOW DATABASES;" | tr -d "| " | grep -v Database | grep -v "information_schema")

    # Iterate through each database
    for mysql_database in ${mysql_databases}; do
        echo "Creating backup for \"${mysql_database}\" database..." | prefix "backup][${mysql_database}"
        # Write backup
        MYSQL_PWD=${mysql_pass} mysqldump --skip-lock-tables -u ${mysql_user} ${mysql_database} > ${backup_location}/${prefix}_${mysql_database}.sql
    done
}

# Store arguments and variables
args_root_password="${1}"
args_destroy_hook="${2:-false}"

###
# Initial bootstrap
###

if [[ ! -f /opt/servant/formulae/mysql_backup-and-import.lockfile ]]; then
    # none

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant/formulae/mysql_backup-and-import.lockfile
fi

###
# Recurring bootstrap
###

# Search for manual created SQL backup lockfiles
for lockfile in $(find /var/www/html/*/ -maxdepth 1 -name create-mysql-backup); do
    # Substitue path to return only vhost name
    virtual_hostname="${lockfile/\/var\/www\/html\//}"
    virtual_hostname="${virtual_hostname/\/create-mysql-backup/}"
    virtual_db_hostname=$(cat "/opt/servant/mysql/${virtual_hostname}")

    backup_all_databases "${virtual_db_hostname}" "${virtual_db_hostname}" "/var/www/html/${virtual_hostname}/backups"
    # Delete lockfile
    rm ${lockfile}
done

# If Vagrant destroy hook fired, backup every database available
if [[ "${args_destroy_hook}" == "true" ]]; then
    echo "Destroy event detected." | prefix "backup"

    backup_all_databases "root" "${args_root_password}" "/var/www/html" "pre-destroy"
fi

# Search for manual created SQL import files
for lockfile in $(find /var/www/html/*/ -maxdepth 1 -name "import.sql"); do
    # Substitue path to return only vhost name
    virtual_hostname="${lockfile/\/var\/www\/html\//}"
    virtual_hostname="${virtual_hostname/\/import.sql/}"
    virtual_db_hostname=$(cat "/opt/servant/mysql/${virtual_hostname}")

    echo "Found SQL import file for \"${virtual_hostname}\"..." | prefix "import"

    MYSQL_PWD=${virtual_db_hostname} mysql -u ${virtual_db_hostname} ${virtual_db_hostname} < ${lockfile}

    # Rename import file so it wont get processed again
    mv ${lockfile} /var/www/html/${virtual_hostname}/successfully-imported.sql
done

# Exit without errors
exit 0
