#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[PHP][${1}] /"
    else
        sed -e "s/^/[PHP] /"
    fi
}

# Store arguments in variables
args_timezone="${1}"
args_php_version="${2}"

# Add apt PPA for PHP versions
# redirect stderr to stdout because both commands use stderr as stdout.
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C 2>&1 | prefix "PPA"
sudo add-apt-repository -y ppa:ondrej/php 2>&1 | prefix "PPA"

# Update repositories
sudo apt-get update | prefix "APT update"

# Store APT prefix based on desired PHP version
if [[ ${args_php_version} == "5.6" ]]; then
    apt_php_prefix="php5.6"
    apt_sqlite_package="sqlite3"
else
    apt_php_prefix="php5"
    apt_sqlite_package="sqlite"
fi

# Install PHP packages
sudo apt-get install -y \
    ${apt_php_prefix}-cli \
    ${apt_php_prefix}-curl \
    ${apt_php_prefix}-fpm \
    ${apt_php_prefix}-gd \
    ${apt_php_prefix}-gmp \
    ${apt_php_prefix}-imagick \
    ${apt_php_prefix}-intl \
    ${apt_php_prefix}-mcrypt \
    ${apt_php_prefix}-mysql \
    ${apt_php_prefix}-pgsql \
    ${apt_php_prefix}-${apt_sqlite_package} \
    ${apt_php_prefix}-xdebug \
    2>&1 | prefix "APT install"
