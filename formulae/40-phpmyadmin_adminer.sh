#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[PMA][${1}] /"
    else
        sed -e "s/^/[PMA] /"
    fi
}

# Store arguments and variables
args_root_password="${1}"
args_install_adminer="${2}"
random_hash="$(date | md5sum | cut -f 1 -d " ")"

###
# Initial bootstrap
###

if [[ ! -f /opt/servant/formulae/phpmyadmin-adminer.lockfile ]]; then
    ###
    # phpMyAdmin
    ###

    # Download and extract latest version
    wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip -O /tmp/source_pma.zip 2>&1 | prefix "source"
    sudo unzip -o /tmp/source_pma.zip -d /var/www/ 2>&1 | prefix "source"
    [[ -d "/var/www/phpmyadmin" ]] && sudo rm -r /var/www/phpmyadmin
    sudo mv /var/www/phpMyAdmin-*-all-languages /var/www/phpmyadmin

    # Write new default virtual host
    sudo bash -c "cat > /etc/apache2/sites-available/00-phpmyadmin.dev.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName phpmyadmin.dev

    DocumentRoot /var/www/phpmyadmin

    <Directory "/var/www/phpmyadmin/">
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/phpmyadmin.dev_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/phpmyadmin.dev_error.log
</VirtualHost>
EOAPACHE

    # Enable config and restart server
    sudo a2ensite 00-phpmyadmin.dev | prefix "config"
    sudo service apache2 restart | prefix "service"

    # Create phpmyadmin storage database
    cat /var/www/phpmyadmin/sql/create_tables.sql | mysql -u root -p${args_root_password} 2>&1 | prefix "storage"
    echo "GRANT SELECT, INSERT, DELETE, UPDATE ON phpmyadmin.* TO 'phpmyadmin'@'localhost' IDENTIFIED BY \"phpmyadmin\"" | mysql -u root -p${args_root_password} 2>&1 | prefix "storage"

    # Adjust default configuration
    cat > /var/www/phpmyadmin/config.inc.php <<EOCONFIG
<?php
  \$cfg['blowfish_secret'] = '${random_hash}';

  \$cfg['UploadDir'] = '';
  \$cfg['SaveDir'] = '';

  \$i = 1;

  \$cfg['Servers'][\$i]['auth_type'] = 'cookie';
  \$cfg['Servers'][\$i]['controluser'] = 'phpmyadmin';
  \$cfg['Servers'][\$i]['controlpass'] = 'phpmyadmin';
  \$cfg['Servers'][\$i]['verbose'] = 'Manual login';

  \$vhosts= glob("/opt/servant/vhosts/*");
  foreach (\$vhosts as \$vhost) {
    \$virtual_hostname = basename(\$vhost);
    \$virtual_db_hostname = file_get_contents('/opt/servant/mysql/'.\$virtual_hostname);

    \$i++;

    \$cfg['Servers'][\$i]['auth_type'] = 'config';
    \$cfg['Servers'][\$i]['controluser'] = 'phpmyadmin';
    \$cfg['Servers'][\$i]['controlpass'] = 'phpmyadmin';
    \$cfg['Servers'][\$i]['user'] = \$virtual_db_hostname;
    \$cfg['Servers'][\$i]['password'] = \$virtual_db_hostname;
    \$cfg['Servers'][\$i]['hide_db'] = 'information_schema';
    \$cfg['Servers'][\$i]['verbose'] = \$virtual_hostname;
  }

EOCONFIG

    # Add info about credentials in login modal
    sudo sed -i "s/' \. __('Server Choice:') \. '/Quick select:/g" /var/www/phpmyadmin/libraries/plugins/auth/AuthenticationCookie.php

    # Create a custom JS file to hide/show user and pass input
    cat > /var/www/phpmyadmin/js/quickselect.js <<EOSCRIPT
\$(function() {
  \$('form.login select#select_server').change(function(){
    if (\$(this).val() != 1){
      \$('#input_username').parent().fadeOut()
      \$('#input_password').parent().fadeOut()
    } else {
      \$('#input_username').parent().fadeIn()
      \$('#input_password').parent().fadeIn()
    }
  });

  if (\$("select#select_server option[value=2]")){
    \$("select#select_server").val("2").trigger("change");
  }
});
EOSCRIPT

    # Include JS file in "load scripts" function
    sudo sed -i "s/menu\-resizer\.js');/menu\-resizer\.js');\n        \$this\->_scripts\->addFile('quickselect\.js');/g" /var/www/phpmyadmin/libraries/Header.php

    ###
    # Adminer
    ###

    # Check if adminer should be intalled
    echo "Install Adminer" | prefix "Adminer"

    sudo mkdir /var/www/adminer
    sudo wget "http://www.adminer.org/latest-mysql.php" -O /var/www/adminer/index.php | prefix "source"

    # Write new default virtual host
    sudo bash -c "cat > /etc/apache2/sites-available/00-adminer.dev.conf" <<EOAPACHE
<VirtualHost *:80>
    ServerName adminer.dev

    DocumentRoot /var/www/adminer

    <Directory "/var/www/adminer/">
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>

    CustomLog \${APACHE_LOG_DIR}/adminer.dev_access.log combined
    ErrorLog \${APACHE_LOG_DIR}/adminer.dev_error.log
</VirtualHost>
EOAPACHE

    # Enable config and restart server
    sudo a2ensite 00-adminer.dev | prefix "config"
    sudo service apache2 restart | prefix "service"

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant/formulae/phpmyadmin-adminer.lockfile
fi

###
# Recurring bootstrap
###

# (none)

# Exit without errors
exit 0

