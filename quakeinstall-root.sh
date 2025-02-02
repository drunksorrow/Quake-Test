#!/bin/bash
# quakeinstall-root.sh - quake live dedicated server installation for root user.

# Culori pentru mesaje
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funcție pentru afișarea mesajelor de succes
success() {
  echo -e "${GREEN}[SUCCES] $1${NC}"
}

# Funcție pentru afișarea mesajelor de avertizare
warn() {
  echo -e "${YELLOW}[AVERTIZARE] $1${NC}"
}

# Funcție pentru afișarea mesajelor de eroare
error() {
  echo -e "${RED}[EROARE] $1${NC}"
  exit 1
}

if [ "$EUID" -ne 0 ]; then
  error "Please run under user 'root'."
fi

echo "Updating 'apt-get'..."
apt-get update
if [ $? -eq 0 ]; then
  success "apt-get updated successfully."
else
  error "Failed to update apt-get."
fi

echo "Installing packages..."
apt-get -y install apache2 python3 python3-setuptools curl nano samba build-essential python3-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6 lib32gcc-s1 python3-pip libtool pkg-config
if [ $? -eq 0 ]; then
  success "Packages installed successfully."
else
  error "Failed to install packages."
fi

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
  
  # Instalare GCC mai vechi pentru evitarea conflictelor cu C++11
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

echo "Installing pyzmq via pip3..."
# Instalare pyzmq în mediul global sau într-un mediu virtual
# Verifică dacă se află într-un mediu virtual și instalează pyzmq acolo
if ! python3 -c 'import sys; print(sys.prefix)' | grep -q "env"; then
  echo "Not in a virtual environment, installing pyzmq globally."
  pip3 install pyzmq
else
  echo "Inside virtual environment, installing pyzmq in venv."
  source venv/bin/activate
  pip install pyzmq
  deactivate
fi

if [ $? -eq 0 ]; then
  success "pyzmq installed successfully."
else
  error "Failed to install pyzmq."
fi

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

echo "Adding user 'qlserver' to sudoers file, and appending NOPASSWD..."
echo "qlserver ALL = NOPASSWD: ALL" >> /etc/sudoers
if [ $? -eq 0 ]; then
  success "User 'qlserver' added to sudoers file successfully."
else
  error "Failed to add user 'qlserver' to sudoers file."
fi

echo "Stopping the Samba services..."
systemctl stop smbd
if [ $? -eq 0 ]; then
  success "Samba services stopped successfully."
else
  warn "Failed to stop Samba services."
fi

echo "Adding home directory sharing to Samba..."
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
if [ $? -eq 0 ]; then
  success "Home directory sharing added to Samba successfully."
else
  error "Failed to add home directory sharing to Samba."
fi

echo "Adding 'www' directory sharing to Samba..."
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
if [ $? -eq 0 ]; then
  success "'www' directory sharing added to Samba successfully."
else
  error "Failed to add 'www' directory sharing to Samba."
fi

echo "Starting the Samba services..."
systemctl start smbd
if [ $? -eq 0 ]; then
  success "Samba services started successfully."
else
  warn "Failed to start Samba services."
fi

echo "Enter the password to use for user 'qlserver' in Samba:"
smbpasswd -a qlserver
if [ $? -eq 0 ]; then
  success "Samba password for 'qlserver' set successfully."
else
  error "Failed to set Samba password for 'qlserver'."
fi

success "All work done for 'root' user, please login to 'qlserver'."
exit 0
