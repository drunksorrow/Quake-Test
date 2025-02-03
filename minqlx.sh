#!/bin/bash

# Actualizarea listei de pachete
sudo apt-get update

# Instalarea Python 3 și dezvoltarea Python 3
sudo apt-get -y install python3 python3-dev

# Afișarea versiunii Python 3 instalate
python3 --version

# Instalarea Redis Server, Git și build-essential
sudo apt-get -y install redis-server git build-essential

# Navigarea în directorul specificat
cd /home/qlserver/steamcmd/steamapps/common/qlds

# Clonarea depozitului minqlx
git clone https://github.com/MinoMino/minqlx.git
cd minqlx

# Compilarea minqlx
make

# Copierea tuturor fișierelor din minqlx/bin în directorul specificat
cp -r bin/* /home/qlserver/steamcmd/steamapps/common/qlds/

# Navigarea înapoi în directorul specificat
cd /home/qlserver/steamcmd/steamapps/common/qlds

# Clonarea depozitului minqlx-plugins
git clone https://github.com/MinoMino/minqlx-plugins.git

# Descărcarea și instalarea pip
wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py --break-system-packages
rm get-pip.py

# Setarea variabilei de mediu pentru a permite instalarea pachetelor Python care pot afecta sistemul
export PIP_BREAK_SYSTEM_PACKAGES=1

# Instalarea dependențelor necesare pentru minqlx-plugins
sudo python3 -m pip install --break-system-packages -r minqlx-plugins/requirements.txt

echo "Scriptul a fost executat cu succes!"
