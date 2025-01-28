#! /bin/bash
# minqlx-setup.sh - Setup Minqlx on Quake Live server for Ubuntu 24.04.

if [ "$(whoami)" != "qlserver" ]; then
  echo "Please run this script as the 'qlserver' user."
  exit 1
fi

echo "Installing Python 3 and Redis..."
sudo apt-get update -y
sudo apt-get -y install python3 python3-dev redis-server build-essential git

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

echo "Configuration of Minqlx is complete."
echo "Please ensure to set your qlx_owner with your SteamID64 in the server configuration."
