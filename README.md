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
      On `./Vagrantfile`:
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
      On `./Vagrantfile`:
      
    <pre>
  ...
  db.vm.network :private_network, ip: "192.168.23.10"
  ...
  app.vm.network :private_network, ip: "192.168.23.11"
  ...
  </pre>
    * VMs are on Ubuntu
      On `./Vagrantfile`:
      <pre>
      ...
      db.vm.box = "ubuntu/focal64"
      ...
      </pre>
    * Port forwarding to host
      On `./Vagrantfile`:
    <pre>
  app.vm.network "forwarded_port", guest:8080, host: 8081,
    auto_correct: true
    app.vm.usable_port_range = 8080..8999
  </pre>
- Subtask II - Database
    * Use of provisioning script to install `MySQL` and any dependency on `DB_VM`
      On `./Vagrantfile`:
      <pre>
      ...
      db.vm.provision "shell" do |s|      
        s.path = "bootstrap_db.sh"
      ...
      end
      ...
      </pre>
      On `bootstrap_db.sh`:
      <pre>
        sudo apt-get update --fix-missing -y
        sudo apt-get install -qq mysql-server
      </pre>
    
