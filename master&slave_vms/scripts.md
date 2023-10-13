VAGRANTSCRIPT.SH



Purpose
This Bash script automates the setup of Vagrant virtual machines. It configures a master VM and a slave VM with specific IP addresses.


# Define box name and IP addresses
BOX_NAME="ubuntu/focal64"
MASTER_IP="192.168.20.10"
SLAVE_IP="192.168.20.11"
BOX_NAME: Specifies the Vagrant box to be used (Ubuntu Focal Fossa 64-bit in this case).
MASTER_IP: Defines the IP address for the master VM.
SLAVE_IP: Defines the IP address for the slave VM.
Function: initialize_vagrant


# Function to initialize Vagrant with a specific box
initialize_vagrant() {
  vagrant init $BOX_NAME
}
Purpose: Initializes Vagrant with the specified box.
Explanation: This function uses vagrant init to create a new Vagrant environment based on the specified box ($BOX_NAME).
Function: generate_vagrantfile


# Function to generate Vagrantfile with configurations
generate_vagrantfile() {
  ...
}
Purpose: Creates a Vagrantfile with custom configurations for the master and slave VMs.
Explanation: This function uses a heredoc (<<EOF) to write the Vagrantfile. It defines two VMs (master and slave_1) with specific configurations, including hostnames and IP addresses. Additionally, it provisions the VMs with necessary shell commands.
Function: start_vagrant


# Function to bring up the Vagrant VMs
start_vagrant() {
  vagrant up
}
Purpose: Starts the Vagrant VMs.
Explanation: This function uses vagrant up to launch the VMs defined in the Vagrantfile.
Function: source_compass


# Function to source another script (compass.sh)
source_compass() {
  source compass.sh
}
Purpose: Sources an external script (compass.sh).
Explanation: This function uses source to execute the commands in the compass.sh script within the current shell session.
Main Execution


# Main script execution
initialize_vagrant
generate_vagrantfile
start_vagrant
source_compass
Purpose: Initiates the execution of the defined functions.
Explanation: This section of the script runs the functions in sequence to set up the Vagrant environment.



COMPASS.SH


Purpose
This Bash script automates the configuration of a master and a slave virtual machine. It performs various tasks like user creation, SSH setup, directory creation, and package updates.

Script Breakdown
User and Password Definitions


NEW_USER="altschool"
NEW_USER_PASSWORD="sijuwade"
NEW_USER: Specifies the username to be created.
NEW_USER_PASSWORD: Sets the password for the new user.
Remote Connection Details


REMOTE_IP="192.168.20.11"
SSH_PASSWORD="vagrant"
REMOTE_IP: Defines the IP address of the remote machine.
SSH_PASSWORD: Stores the SSH password for authentication.
MySQL Password Definition


MYSQL_PASSWORD="mysql_password"
MYSQL_PASSWORD: Sets the MySQL password for later use.
User Management and SSH Key Generation


# Create a new user
CREATE_USER="sudo useradd -m -G sudo $NEW_USER"

# Set user password
SET_USER_PASSWORD="echo -e \"$NEW_USER_PASSWORD\\n$NEW_USER_PASSWORD\\n\" | sudo passwd $NEW_USER"

# Add user to root group
ADD_USER_TO_ROOT="sudo usermod -aG root $NEW_USER"

# Generate SSH key for the new user
GENERATE_SSH_KEY="sudo -u $NEW_USER ssh-keygen -t rsa -b 4096 -f /home/$NEW_USER/.ssh/id_rsa -N \"\" -y"
CREATE_USER: Creates a new user with specified username and adds them to the sudo group.
SET_USER_PASSWORD: Sets the password for the new user.
ADD_USER_TO_ROOT: Adds the new user to the root group.
GENERATE_SSH_KEY: Generates an SSH key for the new user.
Copy SSH Key to Remote Machine


COPY_SSH_KEY="sudo cat /home/$NEW_USER/.ssh/id_rsa.pub | sshpass -p \"$SSH_PASSWORD\" ssh -o StrictHostKeyChecking=no vagrant@$REMOTE_IP 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'"
COPY_SSH_KEY: Copies the public SSH key of the new user to the remote machine's authorized keys file.
Create Directory on Slave


CREATE_SLAVE_DIR="sshpass -p \"$NEW_USER_PASSWORD\" sudo -u $NEW_USER mkdir -p /mnt/altschool/slave"
CREATE_SLAVE_DIR: Creates a directory on the slave machine.
Copy Data to Slave


COPY_SLAVE_DATA="sshpass -p \"$NEW_USER_PASSWORD\" sudo -u $NEW_USER scp -r /mnt/* vagrant@$REMOTE_IP:/home/vagrant/mnt"
COPY_SLAVE_DATA: Copies data from the current machine to the slave machine.
Execute Commands on Master VM


# Execute multiple commands on master VM
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
Executes a series of commands on the master VM, including user creation, SSH key generation, and directory creation.
Update Packages on Master and Slave VMs


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
Updates the packages on both the master and slave VMs.