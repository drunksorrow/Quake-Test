#!/bin/bash

# 1. Instalează dependințele de bază
sudo apt-get update
sudo apt-get -y install python3 python3-dev python3-venv python3-pip redis-server git build-essential

# 2. Clonează și compilează minqlx
cd /home/qlserver/steamcmd/steamapps/common/qlds
git clone https://github.com/MinoMino/minqlx.git
cd minqlx
make

# 3. Copiază fișierele compilate
cp -r minqlx/bin/* /home/qlserver/steamcmd/steamapps/common/qlds/

# 4. Clonează repository-ul de plugin-uri
cd /home/qlserver/steamcmd/steamapps/common/qlds
git clone https://github.com/MinoMino/minqlx-plugins.git

# 5. Creează și activează un mediu virtual Python
python3 -m venv /home/qlserver/steamcmd/steamapps/common/qlds/venv
source /home/qlserver/steamcmd/steamapps/common/qlds/venv/bin/activate

# 6. Instalează dependințele Python în mediul virtual
python3 -m pip install --upgrade pip
python3 -m pip install -r /home/qlserver/steamcmd/steamapps/common/qlds/minqlx-plugins/requirements.txt

echo "Instalarea minqlx și minqlx-plugins a fost finalizată cu succes!"
