#!/bin/bash
# minqlx_install.sh - MinQLX installation for Ubuntu Server 24.04.

# Ensure the script is run as root or with sudo
if [ "$(whoami)" != "root" ]; then
  echo "Please run this script as root or with sudo."
  exit 1
fi

clear
echo "Updating apt-get..."
apt-get update

clear
echo "Installing Python 3, Redis, Git, and build-essential..."
# Install the required dependencies
apt-get -y install python3 python3-dev redis-server git build-essential

clear
echo "Checking Python version..."
# Ensure Python 3.5 or later is installed
python3 --version

clear
echo "Cloning the MinQLX repository..."
# Clone MinQLX repository
git clone https://github.com/MinoMino/minqlx.git
cd minqlx

clear
echo "Compiling MinQLX..."
# Compile MinQLX
make

clear
echo "Copying MinQLX files into the Quake Live server directory..."
# Copy compiled files to your Quake Live server directory (adjust path as needed)
# Replace `/path/to/steamcmd/steamapps/common/qlds/` with the correct path to your Quake Live server
cp -r bin/* /path/to/steamcmd/steamapps/common/qlds/

clear
echo "Cloning MinQLX plugins repository..."
# Clone the MinQLX plugins repository
cd /path/to/steamcmd/steamapps/common/qlds/
git clone https://github.com/MinoMino/minqlx-plugins.git

clear
echo "Installing Python dependencies for MinQLX plugins..."
# Install pip and the Python dependencies for MinQLX plugins
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
rm get-pip.py

export PIP_BREAK_SYSTEM_PACKAGES=1  # Workaround for Debian 12+ users
sudo python3 -m pip install -r minqlx-plugins/requirements.txt

clear
echo "MinQLX installation complete!"
echo "You can now configure and start your Quake Live server with MinQLX."
exit
