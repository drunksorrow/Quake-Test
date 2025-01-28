#! /bin/bash
# quakeinstall-qlserver.sh - Quake Live dedicated server installation for qlserver user on Ubuntu 24.04.

if [ "$(whoami)" != "qlserver" ]; then
  echo "Please run this script as the 'qlserver' user."
  exit 1
fi

echo "Installing SteamCMD..."
mkdir -p ~/steamcmd
cd ~/steamcmd || exit
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz

echo "Installing Quake Live Dedicated Server..."
./steamcmd.sh +login anonymous +force_install_dir ~/steamcmd/steamapps/common/qlds/ +app_update 349090 +quit

echo "Server setup complete."
