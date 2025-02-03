#!/bin/bash

set -e  # Opreste scriptul daca apare o eroare

# Update si instalare dependinte
sudo apt-get update
sudo apt-get -y install python3 python3-dev redis-server git build-essential

# Verificare versiune Python
python3 --version

# Navigare in directorul serverului si clonare minqlx
cd /home/qlserver/steamcmd/steamapps/common/qlds
git clone https://github.com/MinoMino/minqlx.git
cd minqlx
make

# Copiere binare minqlx
cp -r bin/* ../

# Navigare inapoi si clonare minqlx-plugins
cd /home/qlserver/steamcmd/steamapps/common/qlds
git clone https://github.com/MinoMino/minqlx-plugins.git

# Instalare pip si dependinte
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py --break-system-packages
rm get-pip.py
export PIP_BREAK_SYSTEM_PACKAGES=1
sudo python3 -m pip install --break-system-packages -r minqlx-plugins/requirements.txt
