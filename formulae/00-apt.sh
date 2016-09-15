#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[APT][${1}] /"
    else
        sed -e "s/^/[APT] /"
    fi
}

# Store arguments and variables
args_version="${1}"

###
# Initial bootstrap
###

if [[ ! -f /opt/servant_lockfile-apt ]]; then
    # Use apt mirror based on geographical location
    cat > /etc/apt/sources.list.d/apt-geo-mirror.list <<EOAPT
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse
EOAPT

    # Add apt PPA for PHP versions
    # redirect stderr to stdout because both commands use stderr as stdout.
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C 2>&1 | prefix "PPA"
    sudo add-apt-repository -y ppa:ondrej/php 2>&1 | prefix "PPA"
    sudo add-apt-repository -y ppa:ondrej/apache2 2>&1 | prefix "PPA"

    # If MySQL server version 5.6 is requested
    if [[ "${args_mysql_version}" == "5.6" ]]; then
        # Add apt PPA for latest stable MySQL
        sudo add-apt-repository -y ppa:ondrej/mysql-5.6 2>&1 | prefix "PPA"
    fi

    # Updating system
    sudo apt-get update | prefix "update"

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant_lockfile-apt
fi

###
# Recurring bootstrap
###

# Upgrade system packages
sudo apt-get upgrade -y 2>&1 | prefix "upgrade"

# Exit without errors
exit 0
