#!/bin/bash

# Define box name and IP addresses
BOX_NAME="ubuntu/focal64"
MASTER_IP="192.168.20.10"
SLAVE_IP="192.168.20.11"

# Function to initialize Vagrant with a specific box
initialize_vagrant() {
  vagrant init $BOX_NAME
}

# Function to generate Vagrantfile with configurations
generate_vagrantfile() {
  cat <<EOF > Vagrantfile
Vagrant.configure("2") do |config|
  
  # Define slave VM
  config.vm.define "slave_1" do |slave_1|
    slave_1.vm.hostname = "slave-1"
    slave_1.vm.box = "$BOX_NAME"
    slave_1.vm.network "private_network", ip: "$SLAVE_IP"
    slave_1.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update && sudo apt-get upgrade -y
      sudo apt install sshpass -y
      sudo apt-get install -y avahi-daemon libnss-mdns
    SHELL
  end

  # Define master VM
  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.box = "$BOX_NAME"
    master.vm.network "private_network", ip: "$MASTER_IP"
    master.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update && sudo apt-get upgrade -y
      sudo apt-get install -y avahi-daemon libnss-mdns
      sudo apt install sshpass -y
    SHELL
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "2"
  end
end
EOF
}

# Function to bring up the Vagrant VMs
start_vagrant() {
  vagrant up
}

# Function to source another script (compass.sh)
source_compass() {
  source compass.sh
}

# Main script execution
initialize_vagrant
generate_vagrantfile
start_vagrant
source_compass
