#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[MySQL][${1}] /"
    else
        sed -e "s/^/[MySQL] /"
    fi
}

# Store arguments and variables
args_root_password="${1}"
args_version="${2}"
apt_package="mysql-server"

# If MySQL server version 5.6 is requested
if [ ${args_version} == "5.6" ]; then
    # Add apt PPA for latest stable MySQL
    sudo add-apt-repository -y ppa:ondrej/mysql-5.6 2>&1 | prefix "PPA"

    # Update repositories
    sudo apt-get update | prefix "APT update"

    # Append version to package variable
    apt_package+="-5.6"
fi

# Install MySQL without password prompt
# Set username and password to 'root'
echo "mysql-server mysql-server/root_password password ${args_root_password}" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${args_root_password}" | sudo debconf-set-selections

# Install apt package
sudo apt-get install -y ${apt_package} 2>&1 | prefix "APT install"
