#! /bin/bash
# quakeinstall-root.sh - quake live dedicated server installation for root user.

# Ensure the script is run by the root user
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

clear
echo "Updating 'apt-get'..."
apt-get update -y

clear
echo "Installing required packages..."
apt-get install -y \
  apache2 \
  python3 \
  python3-setuptools \
  lib32gcc1 \
  curl \
  nano \
  samba \
  build-essential \
  python3-dev \
  unzip \
  dos2unix \
  mailutils \
  wget \
  lib32z1 \
  lib32stdc++6 \
  libc6 \
  python3-pip

clear
echo "Installing ZeroMQ library..."

# Download ZeroMQ, handle potential download failure
if ! wget http://download.zeromq.org/zeromq-4.1.4.tar.gz; then
  echo "Primary ZeroMQ download failed, trying GitHub..."
  wget https://github.com/zeromq/libzmq/releases/download/v4.1.4/zeromq-4.1.4.tar.gz || {
    echo "Failed to download ZeroMQ from both sources. Please download manually from https://github.com/zeromq/libzmq/releases and place it in the current directory.";
    exit 1;
  }
fi

# Extract, install and clean up ZeroMQ
tar -xvzf zeromq-4.1.4.tar.gz
rm zeromq-4.1.4.tar.gz
cd zeromq-4.1.4
./configure --without-libsodium
make
make install
cd ..
rm -rf zeromq-4.1.4

# Install pyzmq
pip3 install pyzmq

clear
echo "Adding user 'qlserver'..."
useradd -m qlserver
usermod -a -G sudo qlserver
chsh -s /bin/bash qlserver

clear
echo "Enter the password to use for the QLserver account:"
passwd qlserver

clear
echo "Adding user 'qlserver' to sudoers file, appending NOPASSWD..."
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
echo "Installing Supervisor (using pip3)..."
pip3 install supervisor

clear
echo "All work done for 'root' user, please login to 'qlserver'."
exit
