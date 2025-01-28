#! /bin/bash
# quakeinstall-qlserver.sh - quake live dedicated server installation for qlserver user.

# Ensure the script is run by the 'qlserver' user
if [ "$(whoami)" != "qlserver" ]; then
  echo "Please run this script as the 'qlserver' user."
  exit 1
fi

clear
echo "Installing SteamCMD..."

# Ensure necessary tools are installed
if ! command -v wget &> /dev/null || ! command -v tar &> /dev/null; then
  echo "wget or tar is not installed. Installing necessary packages..."
  sudo apt-get install -y wget tar
fi

# Create the SteamCMD directory and install SteamCMD
mkdir -p ~/steamcmd
cd ~/steamcmd
wget -q https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz

clear
echo "Installing Quake Live Dedicated Server..."

# Use SteamCMD to install Quake Live Dedicated Server
./steamcmd.sh +login anonymous +force_install_dir /home/qlserver/steamcmd/steamapps/common/qlds/ +app_update 349090 +quit

clear
# Uncomment and modify the cron job setup if you want automatic updates
#echo "Setting up Cron job for automatic updates..."
#echo "0 8 * * * /home/qlserver/quakeupdate.sh" | crontab -
#clear

echo "Quake Live Dedicated Server installation complete."
exit
