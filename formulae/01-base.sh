#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[Base][${1}] /"
    else
        sed -e "s/^/[Base] /"
    fi
}

# Store arguments in variables
args_timezone="${1}"
args_swap="${2}"

###
# Initial bootstrap
###

if [[ ! -f /opt/servant/formulae/base.lockfile ]]; then
    # Installing Base Packages
    sudo apt-get install -y \
        build-essential \
        curl \
        git \
        unzip \
        2>&1 | prefix "APT install"

    # Setting Timezone to to ${args_timezone} & Locale to en_US.UTF-8
    sudo echo "${args_timezone}" > /etc/timezone
    sudo dpkg-reconfigure -f noninteractive tzdata 2>&1 | prefix "Timezone"
    sudo apt-get install language-pack-en 2>&1 | prefix "Timezone"
    sudo locale-gen en_US | prefix "Timezone"
    sudo update-locale LANG=en_US.UTF-8 LC_CTYPE=en_US.UTF-8 | prefix "Timezone"

    # Check if arguments are set
    if [[ ! ${args_swap} =~ false && ${args_swap} =~ ^[0-9]*$ ]]; then
        # Setting up memory swap
        sudo fallocate -l ${args_swap}M /swapfile | prefix "Swap"
        sudo chmod 600 /swapfile | prefix "Swap"
        sudo mkswap /swapfile | prefix "Swap"
        sudo swapon /swapfile | prefix "Swap"
        sudo echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
        sudo echo "vm.swappiness=0" >> /etc/sysctl.conf
        sudo sysctl -p | prefix "Swap"
    fi

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant/formulae/base.lockfile
fi

###
# Recurring bootstrap
###

# (none)

# Exit without errors
exit 0
