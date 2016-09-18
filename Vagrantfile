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

# Check for required Vagrant plugins
if Vagrant.has_plugin?("vagrant-bindfs") == false || Vagrant.has_plugin?("vagrant-servant-hosts-provisioner") == false || Vagrant.has_plugin?("vagrant-triggers") == false
  puts "Error: Some of the required Vagrant plugins are missing:\n\n"
  puts "  vagrant plugin install vagrant-bindfs vagrant-servant-hosts-provisioner vagrant-triggers"
  exit 1
end

# Create array of static and custom vhosts for vagrant-servant-hosts-provisioner
static_hosts = %w(servant.dev webserver.dev phpmyadmin.dev phpinfo.dev)
custom_hosts = Dir.glob(File.dirname(__FILE__) + "/public/*").select{|f| File.directory?(f)}.map{|f| File.basename(f)}
total_hosts = [*static_hosts, *custom_hosts]

###
# Vagrant bootstrap
###

Vagrant.configure('2') do |config|
  # Base settings
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "servant"
  config.vm.define "servant" do |iwelthost| end

  # Network interfaces
  config.vm.network :private_network, ip: configuration["server"]["ip"]

  # Fix "stdin: is not a tty" warnings while shell provisioning
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Set VM specs
  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--cpus", configuration["server"]["cpus"]]
    vbox.customize ["modifyvm", :id, "--memory", configuration["server"]["memory"]]
    vbox.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  # Shared folder via NFS (and bindfs) for Apache DocumentRoot
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
  config.vm.provision "shell", name: "vhosts_remove-stale", path: "#{configuration["general"]["source_uri"]}/formulae/40-vhosts_remove-stale.sh", args: ["#{configuration["mysql"]["root_password"]}"]
  config.vm.provision "shell", name: "vhosts_add-new", path: "#{configuration["general"]["source_uri"]}/formulae/41-vhosts_add-new.sh", args: ["#{configuration["mysql"]["root_password"]}"]
  config.vm.provision "shell", name: "mysql_backup-and-import", path: "#{configuration["general"]["source_uri"]}/formulae/50-mysql_backup-and-import.sh", args: ["#{configuration["mysql"]["root_password"]}"]

  # Update /etc/hosts file on host and guest
  config.vm.provision :hostsupdate, run: 'always' do |hosts|
      hosts.manage_host = true
      hosts.manage_guest = true
      hosts.aliases = total_hosts
  end

  # Create backups of every database available before destroying machine
  config.trigger.before :destroy do
    run_remote "sudo bash /vagrant/formulae/50-mysql_backup-and-import.sh #{configuration["mysql"]["root_password"]} true"
  end
end
