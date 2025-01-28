#!/bin/bash
# quakeinstall-root.sh - Install Quake Live server on Ubuntu 24.04 for root user

echo "Updating 'apt-get'..."
sudo apt-get update -y

echo "Installing required packages..."
sudo apt-get -y install libc6:i386 zlib1g:i386 build-essential git

echo "Checking and installing 32-bit libraries..."
if ! dpkg --print-architecture | grep -q "i386"; then
  sudo dpkg --add-architecture i386
  sudo apt-get update
fi

echo "Installing required dependencies..."
sudo apt-get -y install libc6:i386 zlib1g:i386

echo "Installing ZeroMQ library..."
if ! wget http://download.zeromq.org/zeromq-4.1.4.tar.gz; then
  echo "Failed to download ZeroMQ from the official server, trying manual download..."
  wget https://github.com/zeromq/libzmq/releases/download/v4.1.4/zeromq-4.1.4.tar.gz || {
    echo "ZeroMQ download failed. Please download manually from https://github.com/zeromq/libzmq/releases and place it in your current directory."
    exit 1
  }
fi

# Dezarhivează și instalează ZeroMQ
tar -xvzf zeromq-4.1.4.tar.gz
cd zeromq-4.1.4 || exit
./configure
make
sudo make install

echo "Installation of dependencies completed successfully."
