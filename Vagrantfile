# -*- mode: ruby -*-
# vi: set ft=ruby :

###
# Variables and configuration
###

configuration_filename = "~/.idev.json"

# Check if configration file exists
if File.exist?(File.expand_path configuration_filename)
  # Store settings
  configuration = JSON.parse(File.read(File.expand_path configuration_filename))
else
  # Return usage information and exit
  sample = File.join(File.dirname(__FILE__), 'config-example.json')
  puts "Error: No config file found (#{configurationname}). To apply the default configuration:\n\n"
  puts "  cp #{sample} ~/.idev.json"
  exit 1
end

###
# Vagrant bootstrap
###

Vagrant.configure('2') do |config|
  config.vm.box = "ubuntu/trusty64"
  config.ssh.forward_agent = true
  config.vm.hostname = configuration["server"]["hostname"]
  config.vm.define configuration["server"]["hostname"] do |iwelthost| end

  config.vm.network :private_network, ip: configuration["server"]["ip"]
  config.vm.network :forwarded_port, guest: 80, host: configuration["general"]["host_port_http"]

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--cpus", configuration["server"]["cpus"]]
    vbox.customize ["modifyvm", :id, "--memory", configuration["server"]["memory"]]
    vbox.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  config.vm.synced_folder ".", "/var/nfs", type: "nfs"
  config.bindfs.bind_folder "/var/nfs", "/vagrant"

  ###
  # Formulae
  ###

  config.vm.provision "shell", path: "#{configuration["general"]["source_uri"]}/formulae/base.sh", args: ["#{configuration["server"]["timezone"]}", "#{configuration["server"]["swap"]}"]
  config.vm.provision "shell", path: "#{configuration["general"]["source_uri"]}/formulae/php.sh", args: ["#{configuration["server"]["timezone"]}", "#{configuration["php"]["version"]}"]
  config.vm.provision "shell", path: "#{configuration["general"]["source_uri"]}/formulae/apache.sh", args: ["#{configuration["server"]["hostname"]}"]
  config.vm.provision "shell", path: "#{configuration["general"]["source_uri"]}/formulae/mysql.sh", args: ["#{configuration["mysql"]["root_password"]}", "#{configuration["mysql"]["version"]}"]
  config.vm.provision "shell", path: "#{configuration["general"]["source_uri"]}/formulae/phpmyadmin.sh", args: ["#{configuration["mysql"]["root_password"]}"]
end
