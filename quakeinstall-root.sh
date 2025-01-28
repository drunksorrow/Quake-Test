#!/bin/bash

# Update apt-get
echo "Updating 'apt-get'..."
sudo apt-get update

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y gcc-14-base:i386 libc6:i386 libgcc-s1:i386 libidn2-0:i386 libunistring5:i386 zlib1g:i386

# Check if ZeroMQ is already downloaded
ZEROMQ_FILE="zeromq-4.1.4.tar.gz"

if [ ! -f "$ZEROMQ_FILE" ]; then
  echo "ZeroMQ not found, attempting to download..."

  # Attempt to download ZeroMQ from the official server
  wget http://download.zeromq.org/zeromq-4.1.4.tar.gz -O "$ZEROMQ_FILE"

  if [ $? -ne 0 ]; then
    echo "Failed to download ZeroMQ from the official server, trying GitHub release..."

    # Attempt to download ZeroMQ from GitHub releases
    wget https://github.com/zeromq/libzmq/releases/download/v4.1.4/zeromq-4.1.4.tar.gz -O "$ZEROMQ_FILE"

    if [ $? -ne 0 ]; then
      echo "ZeroMQ download failed. Please download manually from https://github.com/zeromq/libzmq/releases and place it in your current directory."
      exit 1
    fi
  fi
else
  echo "ZeroMQ file already exists: $ZEROMQ_FILE"
fi

# Extract ZeroMQ and install
echo "Extracting ZeroMQ..."
tar -xvf $ZEROMQ_FILE
cd zeromq-4.1.4
./configure
make
sudo make install

# Update library cache
sudo ldconfig

# Restart necessary services
echo "Restarting necessary services..."
sudo systemctl restart packagekit.service systemd-resolved.service

# Final message
echo "Installation complete. ZeroMQ and dependencies installed successfully."
