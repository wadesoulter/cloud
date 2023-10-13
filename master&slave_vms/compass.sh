#!/bin/bash

set -e

# Define user and password variables
NEW_USER="altschool"
NEW_USER_PASSWORD="sijuwade"

# Define remote IP and SSH password
REMOTE_IP="192.168.20.11"
SSH_PASSWORD="vagrant"

# Define MySQL password
MYSQL_PASSWORD="mysql_password"

# Define commands
CREATE_USER="sudo useradd -m -G sudo $NEW_USER"
SET_USER_PASSWORD="echo -e \"$NEW_USER_PASSWORD\\n$NEW_USER_PASSWORD\\n\" | sudo passwd $NEW_USER"
ADD_USER_TO_ROOT="sudo usermod -aG root $NEW_USER"
GENERATE_SSH_KEY="sudo -u $NEW_USER ssh-keygen -t rsa -b 4096 -f /home/$NEW_USER/.ssh/id_rsa -N \"\" -y"
COPY_SSH_KEY="sudo cat /home/$NEW_USER/.ssh/id_rsa.pub | sshpass -p \"$SSH_PASSWORD\" ssh -o StrictHostKeyChecking=no vagrant@$REMOTE_IP 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'"
CREATE_SLAVE_DIR="sshpass -p \"$NEW_USER_PASSWORD\" sudo -u $NEW_USER mkdir -p /mnt/altschool/slave"
COPY_SLAVE_DATA="sshpass -p \"$NEW_USER_PASSWORD\" sudo -u $NEW_USER scp -r /mnt/* vagrant@$REMOTE_IP:/home/vagrant/mnt"

# Execute commands on master
vagrant ssh master <<EOF
    $CREATE_USER
    $SET_USER_PASSWORD
    $ADD_USER_TO_ROOT
    $GENERATE_SSH_KEY
    $COPY_SSH_KEY
    $CREATE_SLAVE_DIR
    $COPY_SLAVE_DATA
    sudo ps aux > /home/vagrant/running_processes
    exit
EOF

# Execute commands on master again
vagrant ssh master <<EOF
    echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
    sudo apt update -y
    # ... Add other master commands here
    exit 0
EOF

# Execute commands on slave
vagrant ssh slave_1 <<EOF
    echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
    sudo apt update -y
    # ... Add other slave commands here
    exit 0
EOF
