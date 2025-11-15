#!/bin/bash

#=========================================================
#   ⭐ BLUEPRINT AUTO INSTALLER
#      Made for Pterodactyl – by Hopingboyz
#=========================================================

# Colors
CYAN="\e[96m"
GREEN="\e[92m"
RED="\e[91m"
YELLOW="\e[93m"
RESET="\e[0m"

clear

#=========================================================
# ASCII BANNER
#=========================================================
echo -e "${CYAN}"
cat << "EOF"
  ____  _     _    _ ______ _____  _____  _____ _   _ _______     _____ _   _  _____ _______       _      _      ______ _____  
 |  _ \| |   | |  | |  ____|  __ \|  __ \|_   _| \ | |__   __|   |_   _| \ | |/ ____|__   __|/\   | |    | |    |  ____|  __ \ 
 | |_) | |   | |  | | |__  | |__) | |__) | | | |  \| |  | |        | | |  \| | (___    | |  /  \  | |    | |    | |__  | |__) |
 |  _ <| |   | |  | |  __| |  ___/|  _  /  | | | . ` |  | |        | | | . ` |\___ \   | | / /\ \ | |    | |    |  __| |  _  / 
 | |_) | |___| |__| | |____| |    | | \ \ _| |_| |\  |  | |       _| |_| |\  |____) |  | |/ ____ \| |____| |____| |____| | \ \ 
 |____/|______\____/|______|_|    |_|  \_\_____|_| \_|  |_|      |_____|_| \_|_____/   |_/_/    \_\______|______|______|_|  \_\
EOF
echo -e "${RESET}"

echo -e "${GREEN}AUTO BLUEPRINT INSTALLER MADE WITH ❤️ BY HOPINGBOYZ${RESET}"
echo

#=========================================================
# LOADING ANIMATION
#=========================================================
loading() {
    local msg=$1
    echo -ne "${YELLOW}${msg}${RESET}"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.4
    done
    echo
}

#=========================================================
# ERROR CHECK
#=========================================================
check() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ ERROR: $1 failed!${RESET}"
        exit 1
    fi
}

#=========================================================
# UPDATE SYSTEM
#=========================================================
loading "Updating system"
sudo apt update && sudo apt upgrade -y
check "System update"

loading "Installing required packages"
sudo apt install -y curl wget unzip git zip ca-certificates gnupg
check "Package installation"

#=========================================================
# DIRECTORY
#=========================================================
loading "Navigating to Pterodactyl directory"
cd /var/www/pterodactyl || { echo -e "${RED}❌ Pterodactyl directory not found!${RESET}"; exit 1; }

#=========================================================
# DOWNLOAD LATEST BLUEPRINT
#=========================================================
loading "Downloading Blueprint latest release"

LATEST_URL=$(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest \
    | grep '"browser_download_url"' \
    | grep ".zip" \
    | head -n 1 \
    | cut -d '"' -f 4)

if [[ -z "$LATEST_URL" ]]; then
    echo -e "${RED}❌ Could not fetch Blueprint download URL!${RESET}"
    exit 1
fi

wget "$LATEST_URL" -O release.zip
check "Blueprint download"

loading "Extracting Blueprint"
unzip -o release.zip
check "Unzip"

#=========================================================
# INSTALL NODE + YARN
#=========================================================
loading "Adding Node.js repo"

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" \
    | sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null

loading "Installing Node.js"
sudo apt update && sudo apt install -y nodejs
check "Node.js install"

loading "Installing Yarn"
corepack enable
npm i -g yarn
check "Yarn install"

loading "Installing dependencies"
yarn install
check "Yarn dependencies"

#=========================================================
# BLUEPRINT CONFIG
#=========================================================
loading "Creating .blueprintrc"

cat <<EOF >/var/www/pterodactyl/.blueprintrc
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF

check ".blueprintrc creation"

#=========================================================
# RUN BLUEPRINT
#=========================================================
if [[ ! -f "/var/www/pterodactyl/blueprint.sh" ]]; then
    echo -e "${RED}❌ blueprint.sh not found in Pterodactyl folder!${RESET}"
    exit 1
fi

loading "Applying permissions"
chmod +x /var/www/pterodactyl/blueprint.sh

loading "Running Blueprint installer"
bash /var/www/pterodactyl/blueprint.sh

echo
echo -e "${GREEN}✔ Blueprint installation complete!${RESET}"
echo -e "${CYAN}🎉 Your Pterodactyl theme is ready. Enjoy!${RESET}"
echo
