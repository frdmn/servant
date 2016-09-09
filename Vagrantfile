# -*- mode: ruby -*-
# vi: set ft=ruby :


###
# Variables and configuration
###

general = {
  :source_uri    => ".",
}

server = {
  :hostname      => "webserver.dev",
  :ip            => "192.168.50.10",
  :cpus          => "1",
  :memory        => "512",
  :swap          => false,
  :timezone      => "Europe/Berlin"
}

mysql = {
  :root_password => "root",
  :remote        => false,
}

php = {
  :version       => "5.6"
}

###
# Vagrant bootstrap
###

Vagrant.configure('2') do |config|
  config.vm.box = "ubuntu/trusty64"
  config.ssh.forward_agent = true
  config.vm.hostname = server[:hostname]
  config.vm.define "iwelt.dev" do |iwelthost| end

  config.vm.network :private_network, ip: server[:ip]
  config.vm.network :forwarded_port, guest: 80, host: 8000

  config.vm.provider :virtualbox do |vbox|
    vbox.customize ["modifyvm", :id, "--cpus", server[:cpus]]
    vbox.customize ["modifyvm", :id, "--memory", server[:memory]]
    vbox.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
  end

  # Use NFS for the shared folder
  config.vm.synced_folder ".", "/vagrant",
    id: "core",
    :nfs => true,
    :mount_options => ['nolock,vers=3,udp,noatime,actimeo=2,fsc']
end
