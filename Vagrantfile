# -*- mode: ruby -*-
# vi: set ft=ruby :

###
# Variables and configuration
###

general = {
  :source_uri     => ".",
  :host_port_http => "8000",
}

server = {
  :hostname       => "webserver.dev",
  :ip             => "192.168.50.10",
  :cpus           => "1",
  :memory         => "512",
  :swap           => false,
  :timezone       => "Europe/Berlin"
}

mysql = {
  :root_password  => "root",
  :remote         => false,
}

php = {
  :version        => "5.5"
}

###
# Vagrant bootstrap
###

Vagrant.configure('2') do |config|
  config.vm.box = "ubuntu/trusty64"
  config.ssh.forward_agent = true
  config.vm.hostname = server[:hostname]
  config.vm.define server[:hostname] do |iwelthost| end

  config.vm.network :private_network, ip: server[:ip]
  config.vm.network :forwarded_port, guest: 80, host: general[:host_port_http]

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--cpus", server[:cpus]]
    vbox.customize ["modifyvm", :id, "--memory", server[:memory]]
    vbox.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  config.vm.synced_folder ".", "/var/nfs", type: "nfs"
  config.bindfs.bind_folder "/var/nfs", "/vagrant"

  ###
  # Formulae
  ###

  config.vm.provision "shell", path: "#{general[:source_uri]}/formulae/base.sh", args: ["#{server[:timezone]}", "#{server[:swap]}"]
  config.vm.provision "shell", path: "#{general[:source_uri]}/formulae/php.sh", args: ["#{server[:timezone]}", "#{php[:version]}"]
end
