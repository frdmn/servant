#!/usr/bin/env bash

# Function to prefix stdout with current formulae name
function prefix {
    if [[ ! -z "${1}" ]]; then
        sed -e "s/^/[vhost][custom][${1}] /"
    else
        sed -e "s/^/[vhost][custom] /"
    fi
}

###
# Initial bootstrap
###

if [[ ! -f /opt/servant/formulae/vhosts_custom.lockfile ]]; then
    # none

    # Create lockfile to indicate successful inital provisions
    touch /opt/servant/formulae/vhosts_custom.lockfile
fi

###
# Recurring bootstrap
###

# Search for customization files in document roots
for lockfile in $(find /vagrant/public/ -maxdepth 2 -name "servant.json"); do
    # Substitue path to return only vhost name
    virtual_hostname="${lockfile/\/vagrant\/public\//}"
    virtual_hostname="${virtual_hostname/\/servant.json/}"

    hashsum=$(sha1sum ${lockfile} | awk '{ print $1 }')

    # Check if hashsum files exists, if not the servant.json changed in the project root
    if ! stat --printf='' /opt/servant/vhosts_custom/${virtual_hostname}/${hashsum}_* 2>/dev/null; then
        echo "Found new configuration ..." | prefix "${virtual_hostname}"

        # Read servant.json
        config=$(cat ${lockfile} | python -mjson.tool 2>/dev/null)
        config_docroot=$(echo "${config}" | grep document_root | sed 's/document_root//g' | sed 's/[:", ]//g')
        config_alias=$(echo "${config}" | grep server_alias | sed 's/server_alias//g' | sed 's/[:", ]//g')
        vhost_file="/etc/apache2/sites-available/${virtual_hostname}.conf"

        # If custom document root
        if [[ ! -z "${config_docroot}" ]]; then
            docroot="${config_docroot}"

            # Remove possible outdated hashfiles
            rm /opt/servant/vhosts_custom/${virtual_hostname}/*_docroot 2>/dev/null

            # If path doesn't begin with "/", create relative path
            if [[ "${config_docroot}" != /* ]]; then
                docroot="/var/www/html/${virtual_hostname}/htdocs/${config_docroot}"
            fi

            echo "... Setting DocumentRoot to \"${docroot}\"" | prefix "${virtual_hostname}"

            # Adjust default document root
            sed -i "s#DocumentRoot .*#DocumentRoot ${docroot}#g" "${vhost_file}"
            sed -i "s#Directory .*#Directory ${docroot}>#g" "${vhost_file}"

            # Create docroot lockfile
            touch "/opt/servant/vhosts_custom/${virtual_hostname}/${hashsum}_docroot"

            # Make sure to restart Apache at the end of the script
            touch /opt/servant/apache.restart
        fi

        # If custom server alias
        if [[ ! -z "${config_alias}" ]]; then
            echo "... Adding \"${config_alias}\" as ServerAlias" | prefix "${virtual_hostname}"

            # Remove possible outdated hashfiles
            rm /opt/servant/vhosts_custom/${virtual_hostname}/*_alias 2>/dev/null

            # Reset possible previous Alias
            sed -i '/ServerAlias/d' "${vhost_file}"

            # Add server alias
            sed -i "/ServerName .*/a \    ServerAlias ${config_alias}" "${vhost_file}"

             # Create alias lockfile
            touch "/opt/servant/vhosts_custom/${virtual_hostname}/${hashsum}_alias"

            # Make sure to restart Apache at the end of the script
            touch /opt/servant/apache.restart
        fi
    fi
done

# Check if we need to reset to default
for lockfile in $(find /opt/servant/vhosts_custom/ -maxdepth 2 -type f ! -path /opt/servant/vhosts_custom/); do
    # Substitute variables
    stripped_lockfile=${lockfile/\/opt\/servant\/vhosts_custom\//}
    virtual_hostname=${stripped_lockfile%%/*}
    action=${stripped_lockfile#*_}
    hashsum=${stripped_lockfile#*/}
    hashsum=${hashsum%%_*}

    # Store vhost filename
    vhost_file="/etc/apache2/sites-available/${virtual_hostname}.conf"

    # Get hashsum of current file
    if [[ -f "/var/www/html/${virtual_hostname}/servant.json" ]]; then
        current_hashsum=$(sha1sum "/var/www/html/${virtual_hostname}/servant.json" | awk '{ print $1 }')
    else
        current_hashsum=none
    fi

    # Compare hashsums, if they don't match, something changed or config was completly removed
    if [[ ${current_hashsum} != ${hashsum} ]]; then
        # Make sure virtual host is still enabled
        if [[ -f "${vhost_file}" ]]; then
            # If DocumentRoot needs a reset
            if [[ "${action}" == "docroot" ]]; then
                echo "Reset DocumentRoot to default" | prefix "${virtual_hostname}"

                docroot="/var/www/html/${virtual_hostname}/htdocs"

                sed -i "s#DocumentRoot .*#DocumentRoot ${docroot}#g" "${vhost_file}"
                sed -i "s#Directory .*#Directory ${docroot}>#g" "${vhost_file}"
            fi

            # If ServerAlias needs a reset
            if [[ "${action}" == "alias" ]]; then
                echo "Reset ServerAlias to default" | prefix "${virtual_hostname}"

                sed -i '/ServerAlias/d' "${vhost_file}"
            fi

            # Make sure to restart Apache at the end of the script
            touch /opt/servant/apache.restart
        fi

        # Remove lockfile
        rm "${lockfile}"
    fi
done

# Restart Apache if necessary
if [[ -f /opt/servant/apache.restart ]]; then
    sudo service apache2 restart | prefix "service"
    rm /opt/servant/apache.restart
fi

# Exit without errors
exit 0
