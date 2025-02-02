#! /bin/bash
# quakeinstall-qlserver.sh - quake live dedicated server installation for qlserver user.

if [ "$(whoami)" -ne "qlserver" ]
  then echo "Please run under user 'qlserver'."
  exit
fi
echo "Installing SteamCMD..."
mkdir ~/steamcmd; cd ~/steamcmd; wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz; tar -xvzf steamcmd_linux.tar.gz; rm steamcmd_linux.tar.gz
echo "Installing Quake Live Dedicated Server..."
./steamcmd.sh +login anonymous +force_install_dir /home/qlserver/steamcmd/steamapps/common/qlds/ +app_update 349090 +quit
echo "Done."
exit
