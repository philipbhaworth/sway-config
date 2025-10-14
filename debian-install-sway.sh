#!/usr/bin/env bash
# Debian 13 (Trixie) – Core Sway Workstation + Flatpak setup
# Installs full base environment and reminds to reboot before installing Flatpak apps.

set -euo pipefail

# Toggle if you want Chromium (repo) or Google Chrome (vendor repo)
INSTALL_CHROMIUM=true
INSTALL_GOOGLE_CHROME=false  # set true to enable Google repo install

echo "=== Updating and Upgrading System ==="
sudo apt update
sudo apt -y full-upgrade

echo "=== Installing Core Wayland / Sway Stack ==="
sudo apt install -y \
  sway swaybg swayidle swaylock waybar \
  xwayland wl-clipboard grim slurp swappy \
  wofi \
  pipewire pipewire-pulse wireplumber \
  sway-notification-center \
  network-manager-gnome \
  blueman

echo "=== Installing Terminals / Browsers / File Managers ==="
sudo apt install -y \
  kitty foot \
  firefox-esr \
  thunar gvfs gvfs-backends udisks2 thunar-volman tumbler \
  gnome-disk-utility gparted lf

if $INSTALL_CHROMIUM; then
  echo "Installing Chromium..."
  sudo apt install -y chromium
fi

if $INSTALL_GOOGLE_CHROME; then
  echo "Installing Google Chrome from official repo..."
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
  sudo apt update
  sudo apt -y install google-chrome-stable
fi

echo "=== Installing Audio / Media Utilities ==="
sudo apt install -y \
  pavucontrol playerctl pamixer \
  imv mpv \
  mpd mpc ncmpcpp

echo "=== Installing System Monitoring and CLI Tools ==="
sudo apt install -y \
  btop htop fastfetch bat \
  jq ripgrep fzf fd-find lsd tree curl wget xdg-utils stow \
  pciutils usbutils sysstat ethtool zip unzip \
  brightnessctl wlsunset wdisplays \
  autotiling cliphist \
  git tmux net-tools build-essential python3 python3-pip python3-venv pipx rustup

# Notes:
# - Debian's `fd` binary is `fdfind`; alias it later if desired.
# - If `bat` installs as `batcat`, alias it too.

echo "=== Installing Fonts (Debian Packages) ==="
sudo apt install -y \
  fonts-font-awesome \
  fonts-noto fonts-noto-mono fonts-noto-color-emoji \
  fonts-jetbrains-mono fonts-hack fonts-terminus fonts-firacode \
  fonts-ibm-plex fonts-source-code-pro

echo "=== Installing Nerd Fonts (from upstream releases) ==="
tmpdir=$(mktemp -d)
fontdir="/usr/local/share/fonts/NerdFonts"
sudo mkdir -p "$fontdir"

for nf in JetBrainsMono Hack IBMPlexMono Terminus FiraCode SauceCodePro; do
  url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${nf}.zip"
  echo "Downloading ${nf}..."
  if curl -fL "$url" -o "${tmpdir}/${nf}.zip"; then
    unzip -o -q "${tmpdir}/${nf}.zip" -d "${tmpdir}/${nf}"
    find "${tmpdir}/${nf}" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -print0 | sudo xargs -0 -I{} install -m 0644 -D "{}" "${fontdir}/"
  else
    echo "Warning: Failed to fetch Nerd Font ${nf}"
  fi
done

echo "Refreshing font cache..."
sudo fc-cache -f
rm -rf "$tmpdir"

echo "=== Installing Flatpak and Adding Flathub ==="
sudo apt -y install flatpak
# Optional: sudo apt -y install gnome-software-plugin-flatpak

if ! flatpak remote-list | grep -q flathub; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo ""
echo "=== Base Sway Workstation Setup Complete ==="
echo ""
echo "Flatpak and Flathub are configured, but you should REBOOT before installing Flatpak apps"
echo "to ensure portals and session services initialize correctly."
echo ""
echo "You can now safely reboot your system."
