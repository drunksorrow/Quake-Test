#! /bin/bash
# quakeinstall-root.sh - Quake Live Dedicated Server installation for root user.

if [ "$EUID" -ne 0 ]; then
    echo "Please run under user 'root'."
    exit
fi

clear
echo "Updating 'apt-get'..."
apt-get update
clear
echo "Installing packages..."
apt-get -y install apache2 python3 python-setuptools lib32gcc1 curl nano samba build-essential python-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6 libzmq3-dev
clear

# Install Python ZeroMQ binding
echo "Installing Python ZeroMQ bindings..."
easy_install pyzmq || { echo "Failed to install pyzmq."; exit 1; }

clear
echo "Adding user 'qlserver'..."
useradd -m qlserver
usermod -a -G sudo qlserver
chsh -s /bin/bash qlserver
clear
echo "Enter the password to use for QLserver account:"
passwd qlserver
clear
echo "Adding user 'qlserver' to sudoers file, and appending NOPASSWD..."
echo "qlserver ALL = NOPASSWD: ALL" >> /etc/sudoers
clear
echo "Stopping the Samba services..."
/etc/init.d/samba stop
clear
echo "Adding home directory sharing to Samba..."
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
clear
echo "Adding 'www' directory sharing to Samba..."
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
clear
echo "Starting the Samba services..."
/etc/init.d/samba start
clear
echo "Enter the password to use for user 'qlserver' in Samba:"
smbpasswd -a qlserver
clear
echo "Installing Supervisor..."
easy_install supervisor
clear
echo "All work done for 'root' user, please login to 'qlserver'."
exit
