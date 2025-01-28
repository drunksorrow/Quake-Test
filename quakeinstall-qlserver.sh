#!/bin/bash
# quakeinstall-qlserver.sh - Install Quake Live server for qlserver user

if [ "$(whoami)" != "qlserver" ]; then
  echo "Please run this script as the 'qlserver' user."
  exit 1
fi

echo "Installing required packages for qlserver..."
sudo apt-get update -y
sudo apt-get -y install python3 python3-dev redis-server build-essential git

echo "Cloning and compiling Quake Live server..."
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

echo "Minqlx setup is complete. Please configure it with your SteamID64."
