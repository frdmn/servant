#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[APT][${1}] /"
    else
        sed -e "s/^/[APT] /"
    fi
}

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
