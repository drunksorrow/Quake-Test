#! /bin/bash
# quakeinstall-root.sh - Quake Live dedicated server installation for root user on Ubuntu 24.04.

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

echo "Updating 'apt-get'..."
apt-get update -y && apt-get upgrade -y

echo "Installing required packages..."
apt-get -y install apache2 python3 python3-setuptools lib32gcc-s1 curl nano samba build-essential python3-dev unzip dos2unix mailutils wget libc6:i386 zlib1g:i386 g++-multilib redis-server git

echo "Installing ZeroMQ library..."
wget http://download.zeromq.org/zeromq-4.1.4.tar.gz
tar -xvzf zeromq-4.1.4.tar.gz
cd zeromq-4.1.4 || exit
./configure --without-libsodium
make && make install
ldconfig
cd .. && rm -rf zeromq-4.1.4.tar.gz zeromq-4.1.4

echo "Adding user 'qlserver'..."
useradd -m qlserver
usermod -a -G sudo qlserver
chsh -s /bin/bash qlserver
echo "Set a password for the 'qlserver' account:"
passwd qlserver

echo "Adding 'qlserver' to sudoers with NOPASSWD..."
echo "qlserver ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo "Configuring Samba..."
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf

echo "Restarting Samba services..."
systemctl restart smbd

echo "Setting Samba password for 'qlserver':"
smbpasswd -a qlserver

echo "Installing Supervisor..."
python3 -m pip install supervisor

echo "Setup for root is complete. Please log in as 'qlserver' to continue."
