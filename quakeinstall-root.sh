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
apt-get -y install apache2 python3 python-setuptools lib32gcc1 curl nano samba build-essential python-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6
clear

# Install ZeroMQ library with fallback for downloading.
ZERO_MQ_VERSION="4.1.4"
ZERO_MQ_TAR="zeromq-${ZERO_MQ_VERSION}.tar.gz"
ZERO_MQ_URL="https://github.com/zeromq/libzmq/releases/download/v${ZERO_MQ_VERSION}/${ZERO_MQ_TAR}"

echo "Installing ZeroMQ library..."

# Check if ZeroMQ tar file already exists, if not, attempt to download it.
if [ ! -f "$ZERO_MQ_TAR" ]; then
    echo "Downloading ZeroMQ from GitHub..."
    wget "$ZERO_MQ_URL" -O "$ZERO_MQ_TAR"
    if [ $? -ne 0 ]; then
        echo "Failed to download ZeroMQ from GitHub. Please download it manually from $ZERO_MQ_URL and place it in the current directory."
        exit 1
    fi
fi

# Extract and install ZeroMQ
tar -xvzf "$ZERO_MQ_TAR" || { echo "Failed to extract ZeroMQ tarball."; exit 1; }
rm "$ZERO_MQ_TAR"
cd "zeromq-${ZERO_MQ_VERSION}" || { echo "Failed to change to ZeroMQ directory."; exit 1; }
./configure --without-libsodium || { echo "ZeroMQ configure failed."; exit 1; }
make install || { echo "ZeroMQ make install failed."; exit 1; }
cd ..
rm -r "zeromq-${ZERO_MQ_VERSION}"

# Install Python ZeroMQ binding
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
