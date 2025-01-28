#!/bin/bash

# Setăm locația fișierului ZeroMQ
ZEROMQ_FILE="zeromq-4.1.4.tar.gz"

# Verificăm dacă ZeroMQ este deja descărcat
if [ ! -f "$ZEROMQ_FILE" ]; then
  echo "ZeroMQ nu a fost găsit, încercăm să-l descărcăm..."

  # Încercăm să descărcăm ZeroMQ de pe serverul oficial
  wget http://download.zeromq.org/zeromq-4.1.4.tar.gz -O "$ZEROMQ_FILE"

  if [ $? -ne 0 ]; then
    echo "Descărcarea ZeroMQ de pe serverul oficial a eșuat, încercăm GitHub..."

    # Încercăm să descărcăm ZeroMQ de pe GitHub
    wget https://github.com/zeromq/libzmq/releases/download/v4.1.4/zeromq-4.1.4.tar.gz -O "$ZEROMQ_FILE"

    if [ $? -ne 0 ]; then
      echo "Descărcarea ZeroMQ a eșuat. Te rugăm să-l descarci manual de la https://github.com/zeromq/libzmq/releases și să-l plasezi în directorul curent."
      exit 1
    fi
  fi
else
  echo "Fișierul ZeroMQ există deja: $ZEROMQ_FILE"
fi

# Extragem și instalăm ZeroMQ
echo "Descarcăm și instalăm ZeroMQ..."
tar -xvf $ZEROMQ_FILE
cd zeromq-4.1.4
./configure
make
sudo make install

# Actualizăm cache-ul bibliotecii
sudo ldconfig

echo "Instalarea ZeroMQ a fost completă!"
