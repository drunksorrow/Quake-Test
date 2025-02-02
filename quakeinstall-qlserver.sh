#! /bin/bash
# quakeinstall-qlserver.sh - quake live dedicated server installation for qlserver user.

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

# Verifică dacă scriptul este rulat ca 'qlserver'
if [ "$(whoami)" != "qlserver" ]; then
  error "Te rog să rulezi acest script ca utilizator 'qlserver'."
fi

echo -e "${YELLOW}Instalare SteamCMD...${NC}"
mkdir -p ~/steamcmd || error "Nu s-a putut crea directorul 'steamcmd'."
cd ~/steamcmd || error "Nu s-a putut accesa directorul 'steamcmd'."
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz || error "Nu s-a putut descărca SteamCMD."
tar -xvzf steamcmd_linux.tar.gz || error "Nu s-a putut extrage SteamCMD."
rm steamcmd_linux.tar.gz
success "SteamCMD instalat cu succes."

echo -e "${YELLOW}Instalare Quake Live Dedicated Server...${NC}"
./steamcmd.sh +login anonymous +force_install_dir /home/qlserver/steamcmd/steamapps/common/qlds/ +app_update 349090 +quit || error "Instalarea Quake Live Dedicated Server a eșuat."
success "Quake Live Dedicated Server instalat cu succes."

echo -e "${GREEN}Toate sarcinile pentru utilizatorul 'qlserver' au fost finalizate.${NC}"
exit 0
