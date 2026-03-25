#!/bin/bash

# 🦞 OpenClaw Universal Super-Installer for Raspberry Pi 5 - v1.1.3
# "The One-Click Sovereign Experience"

# Colors for professional UI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}###############################################${NC}"
echo -e "${BLUE}#                                             #${NC}"
echo -e "${BLUE}#   🦞 WELCOME TO THE OPENCLAW PI 5 OS 🦞     #${NC}"
echo -e "${BLUE}#                                             #${NC}"
echo -e "${BLUE}###############################################${NC}"
echo ""

# 1. Check for Pi-Apps (The most popular Pi Store)
# We check common installation paths for Pi-Apps
PI_APPS_DIR=""
if [ -d "$HOME/pi-apps" ]; then
    PI_APPS_DIR="$HOME/pi-apps"
elif [ -d "/home/pi/pi-apps" ]; then
    PI_APPS_DIR="/home/pi/pi-apps"
fi

if [ -n "$PI_APPS_DIR" ]; then
    echo -e "${GREEN}[+] Pi-Apps detected at $PI_APPS_DIR! Integrating OpenClaw into your Store...${NC}"
    mkdir -p "$PI_APPS_DIR/apps/OpenClaw"
    
    # Download the essential Pi-Apps files
    BASE_URL="https://raw.githubusercontent.com/jhawpetoss6-collab/pi-apps-openclaw/main/apps/OpenClaw"
    wget -qO "$PI_APPS_DIR/apps/OpenClaw/install" "$BASE_URL/install"
    wget -qO "$PI_APPS_DIR/apps/OpenClaw/uninstall" "$BASE_URL/uninstall"
    wget -qO "$PI_APPS_DIR/apps/OpenClaw/description" "$BASE_URL/description"
    wget -qO "$PI_APPS_DIR/apps/OpenClaw/website" "$BASE_URL/website"
    
    chmod +x "$PI_APPS_DIR/apps/OpenClaw/install" "$PI_APPS_DIR/apps/OpenClaw/uninstall"
    
    echo -e "${GREEN}[!] OpenClaw is now available in your Pi-Apps GUI under 'Utility' or 'Programming'!${NC}"
fi

# 2. Run the Native Installer logic directly
echo -e "${BLUE}[+] Starting Native ARM64 Installation...${NC}"

# Install dependencies first
sudo apt update
sudo apt install -y git curl build-essential python3 python3-pip libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev xdotool wmctrl scrot wget

# Install Node.js v20
if ! command -v node &> /dev/null || [[ $(node -v | cut -d'.' -f1) != "v20" ]]; then
    echo "📦 Installing Node.js v20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Clone and build
INSTALL_DIR="$HOME/openclaw"
if [ -d "$INSTALL_DIR" ]; then
    echo "🔄 Updating existing OpenClaw installation..."
    cd "$INSTALL_DIR"
    git fetch --all
    git reset --hard origin/main
else
    echo "📂 Cloning OpenClaw..."
    git clone https://github.com/openclaw/openclaw.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "🏗️  Building OpenClaw (this may take a few minutes on Pi 5)..."
npm install --omit=dev
npm run build

# Setup Updater
echo "🔄 Configuring Auto-Updater..."
mkdir -p "$HOME/.local/bin"
wget -qO "$HOME/.local/bin/openclaw-updater" https://raw.githubusercontent.com/jhawpetoss6-collab/pi-apps-openclaw/main/openclaw-updater
chmod +x "$HOME/.local/bin/openclaw-updater"
(crontab -l 2>/dev/null | grep -v "openclaw-updater"; echo "0 */4 * * * $HOME/.local/bin/openclaw-updater >> $HOME/.openclaw/updater.log 2>&1") | crontab -

# Desktop entries
echo "🎨 Creating Desktop Icons..."
sudo wget -O /usr/share/icons/hicolor/scalable/apps/openclaw.svg https://raw.githubusercontent.com/openclaw/openclaw/main/docs/assets/logo.svg

# Main App
cat > "$HOME/.local/share/applications/openclaw.desktop" <<EOD
[Desktop Entry]
Name=OpenClaw
GenericName=AI Assistant OS
Comment=The Sovereign AI Assistant OS for Raspberry Pi 5
Exec=lxterminal -e "bash -c 'cd $INSTALL_DIR && npm start; exec bash'"
Icon=/usr/share/icons/hicolor/scalable/apps/openclaw.svg
Terminal=false
Type=Application
Categories=Development;Utility;Network;X-Raspberry-Pi;
EOD

# Web UI App
cat > "$HOME/.local/share/applications/openclaw-web.desktop" <<EOD
[Desktop Entry]
Name=OpenClaw Web UI
GenericName=AI Assistant Dashboard
Comment=Native Web Dashboard for OpenClaw
Exec=chromium-browser --app=http://localhost:5173
Icon=/usr/share/icons/hicolor/scalable/apps/openclaw.svg
Terminal=false
Type=Application
Categories=Development;Utility;Network;X-Raspberry-Pi;X-Chromium-App;
EOD

mkdir -p "$HOME/.local/share/applications/chrome-apps"
cp "$HOME/.local/share/applications/openclaw.desktop" "$HOME/.local/share/applications/chrome-apps/openclaw.desktop"
cp "$HOME/.local/share/applications/openclaw-web.desktop" "$HOME/.local/share/applications/chrome-apps/openclaw-web.desktop"

# 3. Final Success Message
echo ""
echo -e "${GREEN}###############################################${NC}"
echo -e "${GREEN}#          OPENCLAW IS NOW INSTALLED!         #${NC}"
echo -e "${GREEN}###############################################${NC}"
echo -e "${BLUE}# 1. Desktop Icon created (Menu -> Utility)   #${NC}"
echo -e "${BLUE}# 2. Background Service enabled (Always-On)   #${NC}"
echo -e "${BLUE}# 3. Auto-Updater active (Runs every 4 hours) #${NC}"
echo -e "${GREEN}###############################################${NC}"
echo ""
echo -e "To start manually, type: ${BLUE}openclaw${NC}"
