# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
    config.ssh.forward_agent = true
    config.vm.box = "ubuntu/trusty64"
    config.vm.define "simplereach" do |t|
      config.vm.provision "shell", path: "./root_provisioner.sh", privileged: true
      config.vm.provision "shell", path: "./default_user_provisioner.sh", privileged: false
      config.vm.synced_folder ENV['VAGRANT_SYNCED_FOLDER'] || [ENV['HOME'], 'simplereach'].join('/'), "/simplereach"
      config.vm.synced_folder ENV['VAGRANT_LOG_FOLDER'] || [ENV['HOME'], 'simplereach/log'].join('/') , "/var/log"
    end
    config.vm.provider 'virtualbox' do |vb|
      vb.memory = 8192
      vb.cpus = 3
      vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
    end
end
