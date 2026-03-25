#!/bin/bash
alias sudo=""

# 🦞 OpenClaw "Ironman" Edition Installer for Pi 5 - v1.1.7
# Fixed for A2UI Bundling & pnpm Lifecycle

echo "🦞 Starting OpenClaw Ironman Installation..."

# 1. Global Purge to ensure a clean slate
echo "🧹 Purging old versions..."
sudo systemctl stop openclaw 2>/dev/null
sudo systemctl disable openclaw 2>/dev/null
pkill -f "openclaw" 2>/dev/null
rm -f $HOME/.local/share/applications/openclaw*.desktop
rm -f $HOME/.local/share/applications/chrome-apps/openclaw*.desktop

# 2. Install System Dependencies
echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y git curl build-essential python3 python3-pip libpixman-1-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev xdotool wmctrl scrot wget

# 3. Install Node.js v20 and pnpm
if ! command -v node &> /dev/null || [[ $(node -v | cut -d'.' -f1) != "v20" ]]; then
    echo "📦 Installing Node.js v20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
fi

echo "📦 Installing pnpm globally..."
sudo npm install -g pnpm
export PATH="$(npm config get prefix)/bin:$PATH"
pnpm setup
source ~/.bashrc 2>/dev/null || true

# 4. Clone and Build
INSTALL_DIR="$HOME/openclaw"
if [ -d "$INSTALL_DIR" ]; then
    echo "🔄 Refreshing OpenClaw folder..."
    cd "$INSTALL_DIR"
    git fetch --all
    git reset --hard origin/main
else
    echo "📂 Cloning OpenClaw..."
    git clone https://github.com/openclaw/openclaw.git "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

echo "🏗️  Installing dependencies with pnpm (including build tools)..."
# We do NOT omit dev dependencies because the build step needs them!
pnpm install

echo "🏗️  Building OpenClaw (The Deep Build)..."
# Running the build directly with pnpm to ensure pathing
pnpm run build

# 5. Setup Updater
echo "🔄 Configuring Auto-Updater..."
mkdir -p "$HOME/.local/bin"
wget -qO "$HOME/.local/bin/openclaw-updater" https://raw.githubusercontent.com/jhawpetoss6-collab/pi-apps-openclaw/main/openclaw-updater
chmod +x "$HOME/.local/bin/openclaw-updater"
{ crontab -l 2>/dev/null | grep -v "openclaw-updater" > mycron; echo "0 */4 * * * $HOME/.local/bin/openclaw-updater >> $HOME/.openclaw/updater.log 2>&1" >> mycron; crontab mycron; rm mycron; }

# 6. Desktop Icons
echo "🎨 Creating Desktop Icons..."
sudo wget -q --show-progress -O /usr/share/icons/hicolor/scalable/apps/openclaw.png https://raw.githubusercontent.com/openclaw/openclaw/main/docs/assets/logo.png

# Create main launcher
cat > "$HOME/.local/share/applications/openclaw.desktop" <<EOD
[Desktop Entry]
Name=OpenClaw
GenericName=AI Assistant OS
Comment=The Sovereign AI Assistant OS for Raspberry Pi 5
Exec=lxterminal -e "bash -c 'cd $INSTALL_DIR && pnpm start; exec bash'"
Icon=/usr/share/icons/hicolor/scalable/apps/openclaw.png
Terminal=false
Type=Application
Categories=Development;Utility;Network;X-Raspberry-Pi;
EOD

# Create Web UI launcher
cat > "$HOME/.local/share/applications/openclaw-web.desktop" <<EOD
[Desktop Entry]
Name=OpenClaw Web UI
GenericName=AI Assistant Dashboard
Comment=Native Web Dashboard for OpenClaw
Exec=chromium-browser --app=http://localhost:5173
Icon=/usr/share/icons/hicolor/scalable/apps/openclaw.png
Terminal=false
Type=Application
Categories=Development;Utility;Network;X-Raspberry-Pi;X-Chromium-App;
EOD

mkdir -p "$HOME/.local/share/applications/chrome-apps"
cp "$HOME/.local/share/applications/openclaw.desktop" "$HOME/.local/share/applications/chrome-apps/openclaw.desktop"
cp "$HOME/.local/share/applications/openclaw-web.desktop" "$HOME/.local/share/applications/chrome-apps/openclaw-web.desktop"

echo "✅ OpenClaw Ironman Installation Complete!"
echo "🚀 Type 'openclaw' or use the Programming menu icons."
