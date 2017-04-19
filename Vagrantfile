# -*- mode: ruby -*-
# vi: set ft=ruby :
#

if ARGV.empty? or ARGV[0] == '--help'
  puts "
 REQUIRED ENVIRONMENT VARIABLES:
   DOCKER_USERNAME
   DOCKER_EMAIL
   DOCKER_PASSWORD
   these are needed to login to your docker account
   and access docker images

 OPTIONAL ENVIRONMENT VARIABLES
   HOST_REPOSITORY_FOLDER: the folder on your computer container your code repositories
   VAGRANT_REPOSITORY_FOLDER: the folder on the vagrant VM to map to HOST_REPOSITORY_FOLDER
   Example:
     REPOSITORY_FOLDER:  /Users/me/simplereach/repositories
     VAGRANT_REPOSITORY_FOLDER: /home/vagrant/repositories

     with this setting repositories on your computer are visible in the vagrant
     machine under vagrants home directory if/when you vagrant ssh

     LOG_FOLDER: where you want your logs from vagrant to appear on your computer
"
  exit
end


unless Vagrant.has_plugin?("vagrant-docker-login")
  system("vagrant plugin install vagrant-docker-login")
  puts "Dependencies installed, please try the command again."
  exit
end

unless ENV["DOCKER_USERNAME"] && ENV["DOCKER_EMAIL"] && ENV["DOCKER_PASSWORD"]
  puts "Set your DOCKER_USERNAME, DOCKER_EMAIL and DOCKER_PASSWORD environment variable."
  exit
end


REPOSITORY_FOLDER = ENV["REPOSITORY_FOLDER"] || [ENV["HOME"],"simplereach/repositories"].join("/")
VAGRANT_REPOSITORY_FOLDER = ENV["VAGRANT_REPOSITORY_FOLDER"] || "/home/vagrant/repositories"
LOG_FOLDER = ENV["LOG_FOLDER"] || [ENV['HOME'], "simplereach/log/vagrant"].join("/")


unless Dir.exists?(LOG_FOLDER)
  abort("Please create the folder %s and try again" % LOG_FOLDER )
end



Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]

    config.vm.box = "ubuntu/trusty64"
    config.vm.define "simplereach" do |t|
      config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~vagrant/.ssh/id_rsa.pub", run: "always"
      config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "~vagrant/.ssh/id_rsa", run: "always"
      config.vm.provision "file", source: "~/.boto", destination: "~vagrant/.boto", run: "always"
      config.vm.provision "shell", inline: "cat ~vagrant/.ssh/id_rsa.pub >> ~vagrant/.ssh/authorized_keys"
      config.vm.provision "shell", path: "./root_provisioner.sh", privileged: true, env: { "VAGRANT_REPOSITORY_FOLDER": VAGRANT_REPOSITORY_FOLDER, "REPOSITORY_FOLDER": REPOSITORY_FOLDER, "LOG_FOLDER": LOG_FOLDER}
      config.vm.provision "shell", path: "./default_user_provisioner.sh", privileged: false,
          env: { "VAGRANT_REPOSITORY_FOLDER": VAGRANT_REPOSITORY_FOLDER,
                 "REPOSITORY_FOLDER": REPOSITORY_FOLDER,
                 "LOG_FOLDER": LOG_FOLDER
          }
      config.vm.provision :docker
      config.vm.provision :docker_login, username: ENV["DOCKER_USERNAME"], email: ENV["DOCKER_EMAIL"], password: ENV["DOCKER_PASSWORD"], run: "always"
      config.vm.provision "file", source: "~/.boto", destination: "~/.boto"
      config.vm.synced_folder REPOSITORY_FOLDER, VAGRANT_REPOSITORY_FOLDER
      config.vm.synced_folder LOG_FOLDER, "/var/log"

    end
    config.vm.provider 'virtualbox' do |vb|
      vb.name = "simplereach"
      vb.memory = 8192
      vb.cpus = 3
      vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10 ]
    end
end
