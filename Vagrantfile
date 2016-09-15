# -*- mode: ruby -*-
# vi: set ft=ruby :

#                                 _
#  ___  ___ _ ____   ____ _ _ __ | |_
# / __|/ _ \ '__\ \ / / _` | '_ \| __|
# \__ \  __/ |   \ V / (_| | | | | |_
# |___/\___|_|    \_/ \__,_|_| |_|\__|
#
# Servant, a Vagrant based web development system
# © 2016 by Jonas Friedmann licenced under MIT
#

###
# Variables and configuration
###

# Set path for conf file
configuration_filename = "~/.servant.json"

# Check if configration file exists
if File.exist?(File.expand_path configuration_filename)
  # Store settings
  configuration = JSON.parse(File.read(File.expand_path configuration_filename))
else
  # Return usage information and exit
  sample = File.join(File.dirname(__FILE__), 'config.json')
  puts "Error: No config file found (#{configuration_filename}). To apply the default configuration:\n\n"
  puts "  cp #{sample} ~/.servant.json"
  # Exit with error code
  exit 1
end

# Check for custom projects which we add to /etc/hosts
static_hosts = %w(webserver.dev phpmyadmin.dev phpinfo.dev)
custom_hosts = Dir.glob("public/*").select{|f| File.directory?(f)}.map{|f| File.basename(f)}
total_hosts = [static_hosts, custom_hosts]

###
# Vagrant bootstrap
###

Vagrant.configure('2') do |config|
  # Base settings
  config.vm.box = "ubuntu/trusty64"
  config.ssh.forward_agent = true
  config.vm.hostname = "servant"
  config.vm.define "servant" do |iwelthost| end

  # Setup hostmanager plugin
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.aliases = total_hosts

  # Network interfaces
  config.vm.network :private_network, ip: configuration["server"]["ip"]
  config.vm.network :forwarded_port, guest: 80, host: configuration["general"]["host_port_http"]

  # Set VM specs
  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--cpus", configuration["server"]["cpus"]]
    vbox.customize ["modifyvm", :id, "--memory", configuration["server"]["memory"]]
    vbox.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  # Shared folder for Apache DocumentRoot
  config.vm.synced_folder ".", "/var/nfs", type: "nfs"
  config.bindfs.bind_folder "/var/nfs", "/vagrant"

  ###
  # Formulae
  ###

  config.vm.provision "shell", name: "apt", path: "#{configuration["general"]["source_uri"]}/formulae/00-apt.sh", args: ["#{configuration["mysql"]["version"]}"]
  config.vm.provision "shell", name: "base", path: "#{configuration["general"]["source_uri"]}/formulae/00-base.sh", args: ["#{configuration["server"]["timezone"]}", "#{configuration["server"]["swap"]}"]
  config.vm.provision "shell", name: "php", path: "#{configuration["general"]["source_uri"]}/formulae/10-php.sh", args: ["#{configuration["server"]["timezone"]}", "#{configuration["php"]["version"]}"]
  config.vm.provision "shell", name: "apache", path: "#{configuration["general"]["source_uri"]}/formulae/20-apache.sh"
  config.vm.provision "shell", name: "mysql", path: "#{configuration["general"]["source_uri"]}/formulae/20-mysql.sh", args: ["#{configuration["mysql"]["root_password"]}", "#{configuration["mysql"]["version"]}"]
  config.vm.provision "shell", name: "phpmyadmin", path: "#{configuration["general"]["source_uri"]}/formulae/30-phpmyadmin.sh", args: ["#{configuration["mysql"]["root_password"]}"]
  config.vm.provision "shell", name: "vhosts", path: "#{configuration["general"]["source_uri"]}/formulae/40-vhosts.sh", args: ["#{configuration["mysql"]["root_password"]}"]

  ###
  # /etc/hosts provisioner
  ###

  config.vm.provision :hostmanager
end
