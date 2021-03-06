# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

if ARGV[0] != 'plugin'

  required_plugins = ['vagrant-hostmanager', 'vagrant-reload', 'vagrant-cachier', 'vagrant-faster', 'vagrant-google']
  plugins = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
  if not plugins.empty?
    puts "Installing plugins: #{plugins.join(' ')}"
      if system "vagrant plugin install #{plugins.join(' ')}"
        exec "vagrant #{ARGV.join(' ')}"
      else
        abort "Installation of plugins failed."
      end
  end
end

Vagrant.configure("2") do |config|

  #config.vm.provision "shell", privileged: false, path: "global.sh"
  config.vm.boot_timeout = 1800

  config.ssh.private_key_path = "/home/mirjalalcloud/.ssh/google_compute_engine"

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  end

  config.vm.define :DB_VM do |db|
    db.vm.box = "google/gce"
    db.vm.hostname = "db"
    #db.vm.network :private_network, ip: "10.128.0.10"
    
    db.vm.provider "google" do |google, override|
      google.name = "db-vm"
      google.google_project_id = "devops-iba"
      google.google_json_key_location = "/home/mirjalalcloud/GCP-API/key.json"

      google.network_ip = "10.128.0.10"
      
      google.image_family = "ubuntu-2004-lts"
      google.image_project_id = "ubuntu-os-cloud"

      override.ssh.username = "mirjalalcloud"
      override.ssh.private_key_path = "/home/mirjalalcloud/.ssh/google_compute_engine"
    end
    db.vm.provision "shell" do |s|      
      s.path = "bootstrap_db.sh"
      s.args = [ENV['DBNAME'], ENV['DBUSER'], ENV['ROOTPASSWD'], ENV['DBPASSWD']]
    end
  end

  config.vm.define :APP_VM do |app|
    app.vm.box = "google/gce"
    app.vm.hostname = "app"
    #app.vm.network :private_network, ip: "10.128.0.11"
    app.vm.network "forwarded_port", guest:8080, host: 8081,
    auto_correct: true
    app.vm.usable_port_range = 8080..8999
    app.vm.provider "google" do |google, override|
      google.name = "app-vm"
      google.google_project_id = "devops-iba"
      google.google_json_key_location = "/home/mirjalalcloud/GCP-API/key.json"

      google.network_ip = "10.128.0.11"

      google.image_family = "ubuntu-2004-lts"
      google.image_project_id = "ubuntu-os-cloud"

      override.ssh.username = "mirjalalcloud"
      override.ssh.private_key_path = "/home/mirjalalcloud/.ssh/google_compute_engine"
    end
    app.vm.provision "shell", path: "useradd.sh"
    app.vm.provision "shell", path: "bootstrap_app.sh", privileged: false
    app.vm.provision "shell" do |s|
      s.path = "systemd.sh"
      s.args = [ENV['DBPASSWD'], ENV['DBNAME'], ENV['DBUSER']]
    end
    app.vm.provision "shell", path: "check_app.sh"
  end   

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "ubuntu/focal64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
