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

# Store library directory name based on desired PHP version
if [[ ${args_php_version} == "5.6" ]]; then
    php_lib_dir="20131226"
else
    php_lib_dir="20121212"
fi

# Install PHP packages
sudo apt-get install -y \
    php${args_php_version}-cli \
    php${args_php_version}-curl \
    php${args_php_version}-fpm \
    php${args_php_version}-gd \
    php${args_php_version}-gmp \
    php${args_php_version}-imagick \
    php${args_php_version}-intl \
    php${args_php_version}-mbstring \
    php${args_php_version}-mcrypt \
    php${args_php_version}-mysqlnd \
    php${args_php_version}-pgsql \
    php${args_php_version}-sqlite3 \
    php${args_php_version}-xdebug \
    2>&1 | prefix "APT install"

# Use TCP listener instead of Unix socket
sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/${args_php_version}/fpm/pool.d/www.conf
# Only allow localhost clients
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php/${args_php_version}/fpm/pool.d/www.conf
# Run as vagrant instead of www-data
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php/${args_php_version}/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php/${args_php_version}/fpm/pool.d/www.conf
sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/${args_php_version}/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/${args_php_version}/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php/${args_php_version}/fpm/pool.d/www.conf

# Adjust xdebug configuration
sudo bash -c "cat > $(find /etc/php/${args_php_version} -name xdebug.ini)" <<EOXDEBUG
zend_extension=$(find /usr/lib/php/${php_lib_dir} -name xdebug.so)
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
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${args_php_version}/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${args_php_version}/fpm/php.ini

# Set timezone for FPM and CLI
sudo sed -i "s/;date.timezone =.*/date.timezone = ${args_timezone/\//\\/}/" /etc/php/${args_php_version}/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${args_timezone/\//\\/}/" /etc/php/${args_php_version}/cli/php.ini

# Restart FPM
sudo service php${args_php_version}-fpm restart | prefix "service"
