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
if ENV["SERVANT_CONFIG"]
  configuration_filename = File.join(ENV["SERVANT_CONFIG"])
else
  configuration_filename = File.join(File.dirname(__FILE__), 'config.json')
end

# Check if configration file exists
if File.exist?(configuration_filename)
  # Store settings
  configuration = JSON.parse(File.read(configuration_filename))
else
  # Return usage information and exit
  sample = File.join(File.dirname(__FILE__), 'config.sample.json')
  puts "Error: No config file found (#{configuration_filename}). To apply the default configuration:\n\n"
  puts "  cp #{sample} #{configuration_filename}"
  # Exit with error code
  exit 1
end

# Check for required Vagrant plugins
if Vagrant.has_plugin?("vagrant-bindfs") == false || Vagrant.has_plugin?("vagrant-servant-hosts-provisioner") == false || Vagrant.has_plugin?("vagrant-triggers") == false
  puts "Error: Some of the required Vagrant plugins are missing:\n\n"
  puts "  vagrant plugin install vagrant-bindfs vagrant-servant-hosts-provisioner vagrant-triggers"
  exit 1
end

# Function to check for valid JSON
def valid_json?(json)
    JSON.parse(json)
    true
rescue
    false
end

# Create array of static and custom vhosts for vagrant-servant-hosts-provisioner
static_hosts = %w(servant.dev webserver.dev phpmyadmin.dev phpinfo.dev adminer.dev)
custom_hosts = Dir.glob(File.dirname(__FILE__) + "/public/*").select{|f| File.directory?(f)}.map{|f| File.basename(f)}
custom_aliases = Dir.glob(File.dirname(__FILE__) + "/public/**/servant.json").map{|f| JSON.parse(File.read(f))['server_alias'] if valid_json?(File.read(f))}.compact.join(" ")
total_hosts = [*static_hosts, *custom_hosts, *custom_aliases]

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

  config.vm.provision "shell", name: "apt", path: "./formulae/00-apt.sh", args: ["#{configuration["mysql"]["version"]}"]
  config.vm.provision "shell", name: "base", path: "./formulae/01-base.sh", args: ["#{configuration["server"]["timezone"]}", "#{configuration["server"]["swap"]}"]
  config.vm.provision "shell", name: "php", path: "./formulae/10-php.sh", args: ["#{configuration["server"]["timezone"]}", "#{configuration["php"]["version"]}"]
  config.vm.provision "shell", name: "apache", path: "./formulae/20-apache.sh"
  config.vm.provision "shell", name: "mysql", path: "./formulae/30-mysql.sh", args: ["#{configuration["mysql"]["root_password"]}", "#{configuration["mysql"]["version"]}"]
  config.vm.provision "shell", name: "phpmyadmin_adminer", path: "./formulae/40-phpmyadmin_adminer.sh", args: ["#{configuration["mysql"]["root_password"]}", "#{configuration["mysql"]["install_adminer"]}"]
  config.vm.provision "shell", name: "vhosts_remove-stale", path: "./formulae/50-vhosts_remove-stale.sh", args: ["#{configuration["mysql"]["root_password"]}"]
  config.vm.provision "shell", name: "vhosts_add-new", path: "./formulae/51-vhosts_add-new.sh", args: ["#{configuration["mysql"]["root_password"]}"]
  config.vm.provision "shell", name: "vhosts_custom", path: "./formulae/52-vhosts_custom.sh"
  config.vm.provision "shell", name: "mysql_backup-and-import", path: "./formulae/60-mysql_backup-and-import.sh", args: ["#{configuration["mysql"]["root_password"]}"]

  # Update /etc/hosts file on host and guest
  config.vm.provision :hostsupdate, run: 'always' do |hosts|
      hosts.manage_host = true
      hosts.manage_guest = true
      hosts.aliases = total_hosts
  end

  # Create backups of every database available before destroying machine
  config.trigger.before :destroy do
    run_remote "sudo bash /vagrant/formulae/60-mysql_backup-and-import.sh #{configuration["mysql"]["root_password"]} true"
  end
end
