#!/bin/bash

# Check if ZeroMQ is already downloaded
if [ ! -f "zeromq-4.1.4.tar.gz" ]; then
    echo "ZeroMQ not found, attempting to download manually..."
    
    # Try downloading ZeroMQ from alternative sources
    wget http://download.zeromq.org/zeromq-4.1.4.tar.gz || echo "Download from the official server failed, trying GitHub..."

    # Try GitHub as an alternative
    wget https://github.com/zeromq/libzmq/releases/download/v4.1.4/zeromq-4.1.4.tar.gz || echo "Download from GitHub failed."

    # Check if ZeroMQ was successfully downloaded
    if [ ! -f "zeromq-4.1.4.tar.gz" ]; then
        echo "ZeroMQ download failed. Please download it manually from https://github.com/zeromq/libzmq/releases and place it in the current directory."
        exit 1
    fi
fi

# Extract the ZeroMQ archive
echo "Extracting ZeroMQ..."
tar -xvzf zeromq-4.1.4.tar.gz

# Navigate into the extracted directory
cd zeromq-4.1.4

# Install dependencies required for building
echo "Installing required dependencies..."
sudo apt-get update
sudo apt-get install -y build-essential libtool pkg-config

# Compile and install ZeroMQ
echo "Compiling and installing ZeroMQ..."
./configure
make
sudo make install

# Reload shared libraries
echo "Reloading libraries..."
sudo ldconfig

# Continue with Quake-Test installation
cd /root/Quake-Test

# Install other dependencies required for Quake-Test
echo "Installing dependencies for Quake-Test..."
sudo apt-get install -y libsdl2-dev libcurl4-openssl-dev

# Proceed with Quake-Test installation
echo "Installing Quake-Test..."
# Add the necessary commands for installing Quake-Test here (e.g., clone the Quake-Test repository or run other installation commands)

echo "Installation completed successfully!"
