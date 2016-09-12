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

# Use TCP listener instead of Unix socket
sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php5/fpm/pool.d/www.conf
# Only allow localhost clients
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php5/fpm/pool.d/www.conf
# Run as vagrant instead of www-data
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php5/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php5/fpm/pool.d/www.conf

# Adjust xdebug configuration
cat > $(find /etc/php5 -name xdebug.ini) <<EOXDEBUG
zend_extension=$(find /usr/lib/php5 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOXDEBUG

# Display errors globally
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

# Set timezone for FPM and CLI
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/cli/php.ini

# Restart FPM
sudo service php5-fpm restart | prefix "Service"
