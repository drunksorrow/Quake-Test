#! /bin/bash
# quakeinstall-root.sh - quake live dedicated server installation for root user.

# Culori pentru mesaje
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funcție pentru afișarea mesajelor de succes
success() {
  echo -e "${GREEN}[SUCCES] $1${NC}"
}

# Funcție pentru afișarea mesajelor de avertizare
warn() {
  echo -e "${YELLOW}[AVERTIZARE] $1${NC}"
}

# Funcție pentru afișarea mesajelor de eroare
error() {
  echo -e "${RED}[EROARE] $1${NC}"
  exit 1
}

# Verifică dacă scriptul este rulat ca root
if [ "$EUID" -ne 0 ]; then
  error "Te rog să rulezi acest script ca utilizator 'root'."
fi

echo -e "${YELLOW}Actualizare 'apt-get'...${NC}"
apt-get update || error "Nu s-a putut actualiza 'apt-get'."
success "'apt-get' actualizat cu succes."

echo -e "${YELLOW}Instalare pachete...${NC}"
apt-get -y install apache2 python3 python3-setuptools lib32gcc1 curl nano samba build-essential python3-dev unzip dos2unix mailutils wget lib32z1 lib32stdc++6 libc6 || error "Nu s-au putut instala pachetele."
success "Pachete instalate cu succes."

echo -e "${YELLOW}Instalare ZeroMQ...${NC}"
wget https://github.com/zeromq/libzmq/releases/download/v4.3.4/zeromq-4.3.4.tar.gz || error "Nu s-a putut descărca ZeroMQ."
tar -xvzf zeromq-4.3.4.tar.gz || error "Nu s-a putut extrage ZeroMQ."
rm zeromq-4.3.4.tar.gz
cd zeromq-4.3.4 || error "Nu s-a putut accesa directorul ZeroMQ."
./configure --without-libsodium || error "Configurarea ZeroMQ a eșuat."
make install || error "Instalarea ZeroMQ a eșuat."
cd ..
rm -r zeromq-4.3.4
pip3 install pyzmq || error "Instalarea pyzmq a eșuat."
success "ZeroMQ instalat cu succes."

echo -e "${YELLOW}Adăugare utilizator 'qlserver'...${NC}"
useradd -m qlserver || warn "Utilizatorul 'qlserver' există deja."
usermod -a -G sudo qlserver || error "Nu s-a putut adăuga 'qlserver' la grupul 'sudo'."
chsh -s /bin/bash qlserver || error "Nu s-a putut schimba shell-ul pentru 'qlserver'."
echo -e "${YELLOW}Introdu parola pentru utilizatorul 'qlserver':${NC}"
passwd qlserver || error "Setarea parolei pentru 'qlserver' a eșuat."
success "Utilizator 'qlserver' creat și configurat cu succes."

echo -e "${YELLOW}Adăugare 'qlserver' la sudoers...${NC}"
echo "qlserver ALL = NOPASSWD: ALL" >> /etc/sudoers || error "Nu s-a putut adăuga 'qlserver' la sudoers."
success "'qlserver' adăugat la sudoers cu succes."

echo -e "${YELLOW}Oprire servicii Samba...${NC}"
systemctl stop smbd || error "Nu s-a putut opri Samba."
success "Samba oprit cu succes."

echo -e "${YELLOW}Configurare partajare directoare în Samba...${NC}"
echo -e "\n[homes]\n    comment = Home Directories\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf || error "Nu s-a putut configura partajarea 'homes'."
echo -e "\n[www]\n    comment = WWW Directory\n    path = /var/www\n    browseable = yes\n    read only = no\n    writeable = yes\n    create mask = 0755\n    directory mask = 0755" >> /etc/samba/smb.conf || error "Nu s-a putut configura partajarea 'www'."
success "Samba configurat cu succes."

echo -e "${YELLOW}Pornire servicii Samba...${NC}"
systemctl start smbd || error "Nu s-a putut porni Samba."
success "Samba pornit cu succes."

echo -e "${YELLOW}Setare parolă Samba pentru 'qlserver'...${NC}"
smbpasswd -a qlserver || error "Nu s-a putut seta parola Samba pentru 'qlserver'."
success "Parolă Samba setată cu succes."

echo -e "${GREEN}Toate sarcinile pentru utilizatorul 'root' au fost finalizate. Te rog să te conectezi ca 'qlserver'.${NC}"
exit 0
