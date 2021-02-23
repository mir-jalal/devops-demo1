# DevOps - demo1

___

## Step 1 - Create and initialize a virtual machine on *Google Cloud Platform*

1.1. Creating a virtual machine with nested virtualization:

`gcloud compute instances create devops-image-base --image-family=projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts --zone=us-central1-b`

`gcloud compute instances stop devops-image-base --zone=us-central1-b`

`gcloud compute images create devops-demo --source-disk=devops-image-base --source-disk-zone=us-central1-b --licenses="https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"`

`gcloud compute instances create devops-demo-vm --zone=us-central1-b --image=devops-demo --machine-type=n2-standard-2 --boot-disk-size=50GB`

1.2. Checked if nested virtualization is on:

`grep -cw vmx /proc/cpuinfo`

## Step 2 - Enable SSH from outside local network with password authentication

2.1. Modify following line in the file `sudo nano /etc/ssh/sshd_config`:

`PasswordAuthentication yes`

2.2. Then restart sshd to apply updates

`sudo service sshd restart`

2.3. Update user password `mirjalalcloud`

`sudo passwd mirjalalcloud`

Make `mirjalalcloud` *sudo user*

`sudo usermod -aG sudo mirjalalcloud`

## Step 3 - Install and Initialize vagrant and required packages

`sudo apt update`

`sudo apt upgrade`

`sudo apt install virtualbox`

`sudo apt install vagrant`

## Step 4 - Clone this repository on your Virtual Machine

Use following link to clone repository: <https://github.com/mir-jalal/devops-demo1.git>

`git clone https://github.com/mir-jalal/devops-demo1.git`

## Step 5 - Now you can up the machine and see what happens

'cd ./devops-demo1'

'vagrant up --provision'

### Optional Step 5.1 - Vagrant issues

For better running I recommend you to first up each machine one by one and later if everything okay provision the machines.

'vagrant up DB_VM'

'vagrant up APP_VM'

'vagrant provision'

## Working with Vagrantfile and other scripts
___

- Subtask I - Infrastructure
    * Description of two virtual machines using Vagrantfile for deployment of the application (codename APP_VM) and the database (codename DB_VM)
      In `./Vagrantfile`:
      <pre>
        ...
        config.vm.define :DB_VM do |db|
            db.vm.box = "ubuntu/focal64"
            db.vm.hostname = "db"
        ...
            db.vm.provider "virtualbox" do |vb|
                vb.name = "DB_VM"
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vb.customize ["modifyvm", :id, "--ioapic", "on"]
                vb.memory = "3072"
                vb.cpus = "3"
            end
        ...
        end

        config.vm.define :APP_VM do |app|
        ...
            app.vm.hostname = "app"
        ...
            app.vm.provider "virtualbox" do |vb|
                vb.name = "APP_VM"
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vb.customize ["modifyvm", :id, "--ioapic", "on"]
                vb.memory = "3072"
                vb.cpus = "3"
            end
        ...
        end
        ...
  </pre>
  
    * Use of private networking feature for easy VM communication 
      In `./Vagrantfile`:
        <pre>
        ...
        db.vm.network :private_network, ip: "192.168.23.10"
        ...
        app.vm.network :private_network, ip: "192.168.23.11"
        ...
        </pre>
    * VMs are on Ubuntu
      In `./Vagrantfile`:
      <pre>
      ...
      db.vm.box = "ubuntu/focal64"
      ...
      </pre>
    * Port forwarding to host
      In `./Vagrantfile`:
      <pre>
      app.vm.network "forwarded_port", guest:8080, host: 8081,
      auto_correct: true
      app.vm.usable_port_range = 8080..8999
      </pre>
  
- Subtask II - Database
    * Use of provisioning script to install `MySQL` and any dependency on `DB_VM`
      
      In `./Vagrantfile`:
      <pre>
      ...
      db.vm.provision "shell" do |s|      
        s.path = "bootstrap_db.sh"
      ...
      end
      ...
      </pre>
      In `bootstrap_db.sh`:
      <pre>
      sudo apt-get update --fix-missing -y
      sudo apt-get install -qq mysql-server
      ...
      </pre>
    
    * Customization of the database to accept connections only from private network subnet.
      
      In `bootstrap_db.sh`:
        <pre>
        sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
  </pre>
  
    * Creation of a non-root user and password. 

      In `bootstrap_db.sh`:
      <pre>
      Q2="CREATE USER IF NOT EXISTS'$DBUSER'@'192.168.23.%' IDENTIFIED BY '$DBPASSWD';"
      </pre>
    
    * Creation a database in mysql and grant all privileges for the DB_USER to access the database.
    
        In `bootstrap_db.sh`:
        <pre>
      Q1="CREATE DATABASE IF NOT EXISTS $DBNAME;"
      ...
      Q3="GRANT ALL ON $DBNAME.* TO '$DBUSER'@'192.168.23.%';"
      Q4="FLUSH PRIVILEGES;"

      SQL="${Q1}${Q2}${Q3}${Q4}"
      
      $MYSQL -uroot -p$ROOTPASSWD -e "$SQL"
      </pre>
    
      > Note: Here Environmental variables are used. So you should have following Environmental variables beforehand:
      > + DBNAME
      > + DBUSER
      > + DBPASSWD
      > + ROOTPASSWD
      >> You might get following error message if you don't set these environmental variables. So use `export` command to add environmental variables:
      >> `Shell provisioner 'args' must be a string or array.`
        
- Subtask III - Application
    * Creation a non-root user for APP_VM.
      
        In `useradd.sh`:
        <pre>
      useradd -m -s /bin/bash -U demo_user -u 2302
      cp -pr /home/vagrant/.ssh /home/demo_user/
      chown -R demo_user:demo_user /home/demo_user
      echo "%demo_user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/demo_user
      </pre>
    
    * Use of provisioner to install Java JDK, git and other dependencies on APP_VM.
    
        In `Vagrantfile`:
        <pre>
      app.vm.provision "shell", path: "bootstrap_app.sh", privileged: false
      </pre>
    
        In `bootstrap_app.sh`:
      <pre>
      sudo apt-get update --fix-missing -y
      sudo apt-get install openjdk-14-jdk -y
      sudo apt-get install mysql-server -y
      </pre>
    
    * Clone [this repository](https://gitlab.com/mir.jalal/demo1).
        
        In `bootstrap_app.sh`:
        <pre>
      function pull_clone {
          Dir=$(basename "$1" .git)
          if [[ -d "$Dir" ]]; then
          cd $Dir
          git pull
          else
          git clone "$1" && cd $Dir
          fi
          }
        
        pull_clone https://gitlab.com/mir.jalal/demo1
      </pre>
    
    * Use of the Maven tool to package the application.
        
        In `bootstrap.sh`:
        <pre>
      chmod +x mvnw
      ./mvnw clean package
      </pre>
    
    * Run the application with the APP_USER using the java -jar command.
    
        To run the application, I used systemctl to create service and started it so, provisioning is not waiting till the application stops.
        
        <pre>
      #!/usr/bin/env bash

      [Unit]
      Description=Petclinic Java Spring Boot
      
      [Service]
      User=demo_user
      WorkingDirectory=/home/vagrant/demo1
      Environment="MYSQL_PASS=$1"
      Environment="MYSQL_URL=jdbc:mysql://db:3306/$2"
      Environment="MYSQL_USER=$3"
      ExecStart=/home/vagrant/petclinic.sh
      SuccessExitStatus=143
      TimeoutStopSec=10
      Restart=on-failure
      RestartSec=5
        
      [Install]
      WantedBy=multi-user.target
      </pre>
    
        > Note: I used `petclinic.sh` file, so we can check whether database is up or not as it uses in-memory database (H2) when `MySQL` is down
      