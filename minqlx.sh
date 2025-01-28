#!/bin/bash
# minqlx-setup.sh - Setup Minqlx on Quake Live server for Ubuntu 24.04.

if [ "$(whoami)" != "qlserver" ]; then
  echo "Please run this script as the 'qlserver' user."
  exit 1
fi

echo "Installing Python 3 and Redis..."
sudo apt-get update -y
sudo apt-get -y install python3 python3-dev redis-server build-essential git

echo "Checking and installing required 32-bit libraries..."
if ! dpkg --print-architecture | grep -q "i386"; then
  sudo dpkg --add-architecture i386
  sudo apt-get update
fi

# Instalează pachetele i386, dacă nu sunt deja instalate
sudo apt-get -y install libc6:i386 zlib1g:i386

echo "Cloning and compiling Minqlx..."
cd ~/steamcmd/steamapps/common/qlds || exit
git clone https://github.com/MinoMino/minqlx.git
cd minqlx || exit
make
cp -r bin/* ..

echo "Installing Minqlx plugins and dependencies..."
cd ~/steamcmd/steamapps/common/qlds || exit
git clone https://github.com/MinoMino/minqlx-plugins.git
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
rm get-pip.py
export PIP_BREAK_SYSTEM_PACKAGES=1  # For Debian 12+ users
python3 -m pip install -r minqlx-plugins/requirements.txt

echo "Installing ZeroMQ library..."
# Încearcă să descarci ZeroMQ de la sursa oficială
if ! wget http://download.zeromq.org/zeromq-4.1.4.tar.gz; then
  echo "Failed to download ZeroMQ from the official server, trying manual download..."

  # Dacă descărcarea eșuează, poți să descarci manual și să-l instalezi manual
  wget https://github.com/zeromq/libzmq/releases/download/v4.1.4/zeromq-4.1.4.tar.gz || {
    echo "ZeroMQ download failed. Please download manually from https://github.com/zeromq/libzmq/releases and place it in your current directory."
    exit 1
  }
fi

# Dezarhivează și instalează ZeroMQ
tar -xvzf zeromq-4.1.4.tar.gz
cd zeromq-4.1.4 || exit
./configure
make
sudo make install

echo "Configuration of Minqlx is complete."
echo "Please ensure to set your qlx_owner with your SteamID64 in the server configuration."
