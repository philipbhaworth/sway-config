#!/bin/bash
# Complete Debian 13 Trixie Sway Installation Script
# Run this on a fresh minimal Debian 13 Trixie install

set -e

echo "=== Updating System ==="
sudo apt update && sudo apt upgrade -y

echo "=== Installing Core Sway Components ==="
sudo apt install -y \
    sway \
    swaybg \
    swayidle \
    swaylock \
    waybar \
    xwayland \
    wl-clipboard \
    grim \
    slurp \
    swappy

echo "=== Installing Launchers & Tools ==="
sudo apt install -y \
    wofi \
    kitty \
    thunar \
    gvfs \
    gvfs-backends \
    udisks2 \
    thunar-volman \
    tumbler \
    sway-notification-center

echo "=== Installing Audio/Media Control ==="
sudo apt install -y \
    pipewire \
    pipewire-pulse \
    wireplumber \
    pavucontrol \
    playerctl \
    pamixer

echo "=== Installing System Utilities ==="
sudo apt install -y \
    brightnessctl \
    power-profiles-daemon

echo "=== Installing Applications ==="
sudo apt install -y \
    firefox-esr

echo "=== Installing Fonts ==="
sudo apt install -y \
    fonts-font-awesome \
    fonts-noto \
    fonts-noto-mono

echo "=== Installing Dotfile Management ==="
sudo apt install -y \
    stow \
    git

echo "=== Installing Development Tools ==="
sudo apt install -y \
    vim \
    curl \
    wget \
    tmux \
    net-tools \
    tree \
    build-essential \
    python3-pip \
    python3-venv

echo ""
echo "=== Core Installation Complete ==="
echo ""
echo "Next steps:"
echo "1. Clone your dotfiles repo to ~/sway-config"
echo "2. Run the stow commands (see guide below)"
echo "3. Copy wallpaper to ~/wallpapers/"
echo "4. Install VSCodium/Sublime Text if needed"
echo ""
