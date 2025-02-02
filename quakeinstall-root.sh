#! /bin/bash
# quakeinstall-root.sh - quake live dedicated server installation for root user.

if [ "$EUID" -ne 0 ]
  then echo "Please run under user 'root'."
  exit
fi

clear
echo "Updating 'apt-get'..."
apt-get update

clear
echo "Installing packages..."
apt-get -y install apache2 python3 python3-setuptools lib32gcc1 curl nano samba build-essential python3-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6

clear
echo "Installing ZeroMQ library..."
wget https://github.com/zeromq/libzmq/releases/download/v4.3.4/zeromq-4.3.4.tar.gz
tar -xvzf zeromq-4.3.4.tar.gz
rm zeromq-4.3.4.tar.gz
cd zeromq-4.3.4
./configure --without-libsodium
make install
cd ..
rm -r zeromq-4.3.4
pip3 install pyzmq

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
systemctl stop smbd

clear
echo "Adding home directory sharing to Samba..."
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf

clear
echo "Adding 'www' directory sharing to Samba..."
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf

clear
echo "Starting the Samba services..."
systemctl start smbd

clear
echo "Enter the password to use for user 'qlserver' in Samba:"
smbpasswd -a qlserver

clear
echo "Installing Supervisor..."
pip3 install supervisor

clear
echo "All work done for 'root' user, please login to 'qlserver'."
exit
