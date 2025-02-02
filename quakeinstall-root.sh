#! /bin/bash
# quakeinstall-root.sh - quake live dedicated server installation for root user (debug version).

# Definire culori pentru mesaje
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funcții pentru mesaje
success() {
  echo -e "${GREEN}[SUCCES] $1${NC}"
}
warn() {
  echo -e "${YELLOW}[AVERTIZARE] $1${NC}"
}
error() {
  echo -e "${RED}[EROARE] $1${NC}" >&2
  exit 1
}

if [ "$EUID" -ne 0 ]; then
  error "Trebuie să rulezi acest script ca root!"
fi

success "Utilizator root confirmat."

warn "Actualizare lista de pachete..."
apt-get update || error "Eșec la actualizarea 'apt-get'."
success "Lista de pachete actualizată."

warn "Instalare pachete necesare..."
apt-get -y install apache2 python3 python3-setuptools lib32gcc-s1 curl nano samba build-essential python3-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6 || error "Eșec la instalarea pachetelor."
success "Toate pachetele necesare au fost instalate."

warn "Instalare librărie ZeroMQ..."
wget http://download.zeromq.org/zeromq-4.1.4.tar.gz && tar -xvzf zeromq-4.1.4.tar.gz && rm zeromq-4.1.4.tar.gz && cd zeromq-* && ./configure --without-libsodium && make install && cd .. && rm -r zeromq-* && easy_install pyzmq || error "Eșec la instalarea ZeroMQ."
success "Librăria ZeroMQ a fost instalată."

warn "Adăugare utilizator 'qlserver'..."
useradd -m qlserver && usermod -a -G sudo qlserver && chsh -s /bin/bash qlserver || error "Eșec la crearea utilizatorului."
success "Utilizatorul 'qlserver' a fost creat."

warn "Setează parola pentru 'qlserver':"
passwd qlserver || error "Eșec la setarea parolei."
success "Parola utilizatorului 'qlserver' a fost setată."

echo "qlserver ALL = NOPASSWD: ALL" >> /etc/sudoers || error "Eșec la adăugarea lui 'qlserver' în sudoers."
success "Utilizatorul 'qlserver' adăugat în sudoers."

warn "Oprire servicii Samba..."
systemctl stop smbd || warn "Serviciul Samba nu a putut fi oprit. Poate nu era pornit."

warn "Configurare Samba..."
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf

echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf
success "Configurare Samba completă."

warn "Pornire serviciu Samba..."
systemctl start smbd || error "Eșec la pornirea Samba."
success "Samba pornit."

warn "Setează parola pentru Samba pentru utilizatorul 'qlserver':"
smbpasswd -a qlserver || error "Eșec la setarea parolei Samba."
success "Parola Samba setată pentru 'qlserver'."

success "Instalarea a fost finalizată. Acum te poți autentifica în contul 'qlserver'."
