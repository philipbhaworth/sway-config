#!/usr/bin/env bash
# Fedora Sway Spin – add-on tools + Flatpak/Flathub (no Sway install; no rofi-wayland)
# Run on Fedora Sway Spin. Ends with a reboot reminder (no prompt).

set -euo pipefail

# Toggle if you want Chromium (repo) or Google Chrome (vendor repo)
INSTALL_CHROMIUM=true
INSTALL_GOOGLE_CHROME=false   # set true to enable Google Chrome repo install

echo "=== Updating system ==="
sudo dnf -y upgrade --refresh

echo "=== Desktop extras (NO sway/rofi-wayland here) ==="
# Spin already includes sway, swaylock, swayidle, waybar, foot, rofi-wayland, etc.
sudo dnf install -y \
  wl-clipboard grim slurp swappy \
  pipewire pipewire-pulse wireplumber \
  SwayNotificationCenter \
  NetworkManager-applet \
  blueman

echo "=== Terminals / Browsers / File Managers ==="
# WezTerm will be installed later via Flatpak after reboot
sudo dnf install -y \
  kitty \
  firefox \
  thunar thunar-volman tumbler gvfs gvfs-smb gvfs-nfs udisks2 \
  gnome-disk-utility gparted lf

if $INSTALL_CHROMIUM; then
  echo "Installing Chromium..."
  sudo dnf install -y chromium
fi

if $INSTALL_GOOGLE_CHROME; then
  echo "Installing Google Chrome from official repo..."
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager --add-repo https://dl.google.com/linux/chrome/rpm/stable/x86_64
  sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
  sudo dnf install -y google-chrome-stable
fi

echo "=== Audio / Media Utilities ==="
sudo dnf install -y \
  pavucontrol playerctl pamixer \
  imv mpv \
  mpd mpc ncmpcpp

echo "=== System monitoring & CLI tools ==="
sudo dnf install -y \
  btop htop fastfetch bat \
  jq ripgrep fzf fd-find lsd tree curl wget xdg-utils stow \
  pciutils usbutils sysstat ethtool zip unzip \
  brightnessctl wlsunset wdisplays \
  autotiling cliphist \
  git tmux make gcc gcc-c++ python3 python3-pip python3-virtualenv pipx rustup

# Notes:
# - On Fedora, 'fd' binary is typically 'fd' (no alias needed).
# - 'bat' is 'bat' (no 'batcat').

echo "=== Fonts (Fedora packages) ==="
sudo dnf install -y \
  fontawesome-fonts \
  google-noto-sans-fonts google-noto-serif-fonts google-noto-mono-fonts google-noto-emoji-color-fonts \
  jetbrains-mono-fonts hack-fonts terminus-fonts fira-code-fonts \
  ibm-plex-mono-fonts adobe-source-code-pro-fonts

echo "=== Nerd Fonts (from upstream releases) ==="
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

echo "=== Flatpak + Flathub ==="
sudo dnf install -y flatpak
# Optional GUI storefront:
# sudo dnf install -y gnome-software gnome-software-plugin-flatpak

if ! flatpak remote-list | grep -q '^flathub'; then
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo
echo "=== Fedora Sway add-ons setup complete ==="
echo
echo "Flatpak and Flathub are configured. REBOOT before installing Flatpak apps"
echo "to ensure portals and session services initialize correctly."
echo
echo "After reboot, example Flatpak installs:"
echo "  flatpak install -y flathub org.wezfurlong.wezterm"
echo "  flatpak install -y flathub dev.zed.Zed"
echo "  flatpak install -y flathub md.obsidian.Obsidian"
echo "  flatpak install -y flathub dev.vencord.Vesktop"
echo
echo "You can now safely reboot your system."
