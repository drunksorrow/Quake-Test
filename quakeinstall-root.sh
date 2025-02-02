#!/bin/bash
# quakeinstall-root.sh - Quake Live dedicated server installation for root user.

# Colors for messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Success message function
success() {
  echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Warning message function
warn() {
  echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Error message function
error() {
  echo -e "${RED}[ERROR] $1${NC}"
  exit 1
}

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  error "Please run under user 'root'."
fi

# Update apt-get
echo "Updating 'apt-get'..."
apt-get update
if [ $? -eq 0 ]; then
  success "apt-get updated successfully."
else
  error "Failed to update apt-get."
fi

# Install required packages
echo "Installing packages..."
apt-get -y install apache2 python3 python3-setuptools curl nano samba build-essential python3-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6 lib32gcc-s1 python3-pip libtool pkg-config
if [ $? -eq 0 ]; then
  success "Packages installed successfully."
else
  error "Failed to install packages."
fi

# Install ZeroMQ library
echo "Installing ZeroMQ library..."
ZMQ_URL="https://github.com/zeromq/libzmq/releases/download/v4.3.4/zeromq-4.3.4.tar.gz"
ZMQ_FILE="zeromq-4.3.4.tar.gz"
ZMQ_DIR="zeromq-4.3.4"

wget "$ZMQ_URL" -O "$ZMQ_FILE"
if [ $? -eq 0 ]; then
  success "ZeroMQ downloaded successfully."
else
  error "Failed to download ZeroMQ."
fi

if [ -f "$ZMQ_FILE" ]; then
  tar -xvzf "$ZMQ_FILE"
  if [ $? -eq 0 ]; then
    success "ZeroMQ extracted successfully."
  else
    error "Failed to extract ZeroMQ."
  fi
else
  error "ZeroMQ archive not found."
fi

if [ -d "$ZMQ_DIR" ]; then
  cd "$ZMQ_DIR"
  
  # Install GCC for avoiding conflicts with C++11
  apt-get install gcc-9 g++-9
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90
  success "Using GCC 9 to compile."

  ./configure --without-libsodium
  if [ $? -eq 0 ]; then
    success "ZeroMQ configured successfully."
  else
    error "Failed to configure ZeroMQ."
  fi

  make
  if [ $? -eq 0 ]; then
    success "ZeroMQ built successfully."
  else
    error "Failed to build ZeroMQ."
  fi

  make install
  if [ $? -eq 0 ]; then
    success "ZeroMQ installed successfully."
  else
    error "Failed to install ZeroMQ."
  fi

  cd ..
  rm -rf "$ZMQ_FILE" "$ZMQ_DIR"
else
  error "ZeroMQ directory not found."
fi

# Installing pyzmq via pip3
echo "Installing pyzmq via pip3..."

# Check if the system is in a virtual environment
if ! python3 -c 'import sys; print(sys.prefix)' | grep -q "env"; then
  echo "Not in a virtual environment, installing pyzmq globally."
  # Installing pyzmq system-wide using apt
  apt-get install python3-pyzmq
  if [ $? -eq 0 ]; then
    success "pyzmq installed successfully."
  else
    error "Failed to install pyzmq via apt."
  fi
else
  echo "Inside virtual environment, installing pyzmq in venv."
  source venv/bin/activate
  pip install pyzmq
  deactivate
  if [ $? -eq 0 ]; then
    success "pyzmq installed successfully in virtual environment."
  else
    error "Failed to install pyzmq in virtual environment."
  fi
fi

# Adding user 'qlserver'
echo "Adding user 'qlserver'..."
useradd -m qlserver
usermod -a -G sudo qlserver
chsh -s /bin/bash qlserver
echo "Enter the password to use for QLserver account:"
passwd qlserver
if [ $? -eq 0 ]; then
  success "User 'qlserver' added successfully."
else
  error "Failed to add user 'qlserver'."
fi

# Adding user 'qlserver' to sudoers with NOPASSWD
echo "qlserver ALL = NOPASSWD: ALL" >> /etc/sudoers
if [ $? -eq 0 ]; then
  success "User 'qlserver' added to sudoers file successfully."
else
  error "Failed to add user 'qlserver' to sudoers file."
fi

# Stopping Samba services
echo "Stopping the Samba services..."
systemctl stop smbd
if [ $? -eq 0 ]; then
  success "Samba services stopped successfully."
else
  warn "Failed to stop Samba services."
fi

# Adding home directory sharing to Samba
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
if [ $? -eq 0 ]; then
  success "Home directory sharing added to Samba successfully."
else
  error "Failed to add home directory sharing to Samba."
fi

# Adding 'www' directory sharing to Samba
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
if [ $? -eq 0 ]; then
  success "'www' directory sharing added to Samba successfully."
else
  error "Failed to add 'www' directory sharing to Samba."
fi

# Starting Samba services
echo "Starting the Samba services..."
systemctl start smbd
if [ $? -eq 0 ]; then
  success "Samba services started successfully."
else
  warn "Failed to start Samba services."
fi

# Setting Samba password for 'qlserver'
echo "Enter the password to use for user 'qlserver' in Samba:"
smbpasswd -a qlserver
if [ $? -eq 0 ]; then
  success "Samba password for 'qlserver' set successfully."
else
  error "Failed to set Samba password for 'qlserver'."
fi

success "All work done for 'root' user, please login to 'qlserver'."
exit 0
