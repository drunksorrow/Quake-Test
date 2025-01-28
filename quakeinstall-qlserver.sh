#!/bin/bash
# quakeinstall-qlserver.sh - quake live dedicated server installation for qlserver user.

if [ "$(whoami)" != "qlserver" ]; then
  echo "Please run under user 'qlserver'."
  exit 1
fi

clear
echo "Installing SteamCMD..."
mkdir -p ~/steamcmd
cd ~/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
rm steamcmd_linux.tar.gz

clear
echo "Installing Quake Live Dedicated Server..."
./steamcmd.sh +login anonymous +force_install_dir /home/qlserver/steamcmd/steamapps/common/qlds/ +app_update 349090 +quit

clear
#echo "Cronning 'QuakeUpdate.sh'..."
#echo "0 8 * * * /home/qlserver/quakeupdate.sh" > cron
#crontab cron
#rm cron

clear
echo "Done."
exit 0
