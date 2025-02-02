#! /bin/bash
# quakeinstall-root.sh - quake live dedicated server installation for root user on Ubuntu 24.04.

# Definire culori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funcții pentru mesaje colorate
success() { echo -e "${GREEN}[SUCCES] $1${NC}"; }
warn() { echo -e "${YELLOW}[AVERTIZARE] $1${NC}"; }
error() { echo -e "${RED}[EROARE] $1${NC}"; exit 1; }

# Verificare rulare ca root
if [ "$EUID" -ne 0 ]; then
  error "Rulează scriptul ca root!"
fi

success "Actualizare 'apt-get'..."
apt-get update || error "Eșec la actualizarea pachetelor!"

success "Instalare pachete necesare..."
apt-get -y install apache2 python3 python3-pip python3-setuptools lib32gcc-s1 curl nano samba build-essential python3-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6 libzmq3-dev || error "Eșec la instalarea pachetelor!"

success "Instalare ZeroMQ (folosind pip3)..."
pip3 install pyzmq || error "Eșec la instalarea pyzmq!"

success "Adăugare utilizator 'qlserver'..."
useradd -m qlserver && usermod -a -G sudo qlserver && chsh -s /bin/bash qlserver || error "Eșec la adăugarea utilizatorului!"

warn "Introduceți parola pentru utilizatorul 'qlserver':"
passwd qlserver || error "Eșec la setarea parolei!"

success "Adăugare 'qlserver' în sudoers cu NOPASSWD..."
echo "qlserver ALL = NOPASSWD: ALL" >> /etc/sudoers || error "Eșec la modificarea sudoers!"

success "Oprire servicii Samba..."
systemctl stop smbd || error "Eșec la oprirea Samba!"

success "Configurare partajare home în Samba..."
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf || error "Eșec la configurarea Samba!"

success "Configurare partajare 'www' în Samba..."
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf || error "Eșec la configurarea Samba!"

success "Repornire servicii Samba..."
systemctl start smbd || error "Eșec la repornirea Samba!"

warn "Introduceți parola pentru utilizatorul 'qlserver' în Samba:"
smbpasswd -a qlserver || error "Eșec la configurarea parolei Samba!"

success "Instalare completă! Loghează-te ca utilizator 'qlserver'."
exit 0
