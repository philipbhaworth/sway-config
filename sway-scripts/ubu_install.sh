#!/usr/bin/env bash
# install.sh
# Debian 13 (trixie) minimal Sway + Wayland tooling installer (no config writes)
# Updated: use Flameshot (XWayland) for screenshots; grim/slurp removed by default.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
REQUIRED_DIST="trixie"   # Debian 13
USER_NAME="${SUDO_USER:-${USER}}"

# --- Sanity checks -----------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (e.g.,: sudo $0)"; exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found; this script targets Debian-based systems."; exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release
CURRENT_CODENAME="${VERSION_CODENAME:-}"

if [[ -n "$REQUIRED_DIST" && "$CURRENT_CODENAME" != "$REQUIRED_DIST" ]]; then
  echo "Warning: target is Debian '$REQUIRED_DIST', but this system is '$CURRENT_CODENAME'. Continuing in 5s..."
  sleep 5
fi

apt_install() {
  apt-get update
  apt-get install -y --no-install-recommends "$@"
}

# --- Package sets ------------------------------------------------------------
BASE_PKGS=(
  build-essential git curl wget unzip p7zip-full
  htop vim tmux stow tree jq fzf ripgrep bat fd-find
  firefox-esr
)

# Note: grim/slurp removed because Flameshot will be used for screenshots.
SWAY_WAYLAND_PKGS=(
  sway swaylock swayidle swaybg waybar wl-clipboard xwayland
)

# If you want native Wayland screenshot tools as a fallback, uncomment:
# WAYLAND_SCREENSHOT_FALLBACK_PKGS=( grim slurp )

PORTAL_PKGS=( xdg-desktop-portal xdg-desktop-portal-wlr )

TERM_EDITOR_PKGS=( foot kitty pluma )

FILES_STORAGE_PKGS=(
  thunar thunar-volman thunar-archive-plugin
  tumbler ffmpegthumbnailer
  gvfs gvfs-backends gvfs-fuse
  udisks2 file-roller udiskie
  gnome-disk-utility
)

FONTS_THEME_PKGS=(
  fonts-dejavu fonts-noto fonts-noto-color-emoji
  fonts-font-awesome nwg-look
)

AUDIO_NOTIFY_PKGS=(
  pipewire pipewire-audio wireplumber libspa-0.2-bluetooth
  alsa-utils sway-notification-center
  pavucontrol
  libnotify-bin
)

BLUETOOTH_PKGS=( bluez blueman )
NETWORK_PKGS=( network-manager )
POLKIT_PKGS=( lxqt-policykit )
MEDIA_PKGS=( qimgv mpv )
POWER_QOL_PKGS=( brightnessctl gammastep )

# Launchers / desktop utilities
LAUNCHER_UTIL_PKGS=(
  wofi
  wlogout
  swappy
  cliphist
)

# Screenshots (your preference)
SCREENSHOT_PKGS=( flameshot )

# Greeter (installed; you’ll manage config in your dotfiles)
GREETER_PKGS=( greetd tuigreet )

ALL_PKGS=(
  "${BASE_PKGS[@]}"
  "${SWAY_WAYLAND_PKGS[@]}"
  "${PORTAL_PKGS[@]}"
  "${TERM_EDITOR_PKGS[@]}"
  "${FILES_STORAGE_PKGS[@]}"
  "${FONTS_THEME_PKGS[@]}"
  "${AUDIO_NOTIFY_PKGS[@]}"
  "${BLUETOOTH_PKGS[@]}"
  "${NETWORK_PKGS[@]}"
  "${POLKIT_PKGS[@]}"
  "${MEDIA_PKGS[@]}"
  "${POWER_QOL_PKGS[@]}"
  "${LAUNCHER_UTIL_PKGS[@]}"
  "${SCREENSHOT_PKGS[@]}"
  "${GREETER_PKGS[@]}"
  # "${WAYLAND_SCREENSHOT_FALLBACK_PKGS[@]}"  # uncomment if desired
)

echo "==> Installing packages..."
apt_install "${ALL_PKGS[@]}"

# --- Enable core services ----------------------------------------------------
echo "==> Enabling services..."
systemctl enable --now NetworkManager
systemctl enable --now bluetooth || true
systemctl enable --now greetd || true
# PipeWire/WirePlumber are user units; they’ll start on demand.

# --- Flatpak: add Flathub ----------------------------------------------------
if command -v flatpak >/dev/null 2>&1; then
  if ! sudo -u "$USER_NAME" flatpak remotes | grep -q '^flathub'; then
    echo "==> Adding Flathub remote for user: $USER_NAME"
    sudo -u "$USER_NAME" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
fi

# --- Quality of Life: ensure ~/Pictures exists for Flameshot -----------------
sudo -u "$USER_NAME" mkdir -p "/home/$USER_NAME/Pictures"

cat <<'EONEXT'
==> Install complete.

Next steps:
  1) Generate SSH keys:
       ssh-keygen -t ed25519 -C "your_email@example.com"
     Then copy your public key:
       cat ~/.ssh/id_ed25519.pub
     And add it to your GitHub account via the browser.

  2) Launch the browser to add keys / sign in:
       firefox-esr

  3) Clone your dotfiles repo and stow configs (example):
       git clone git@github.com:<you>/<dotfiles>.git ~/.dotfiles
       cd ~/.dotfiles
       stow sway waybar foot kitty   # adjust to your repo layout

  4) Sway keybindings for Kitty + Flameshot (append to ~/.config/sway/config):
       set $term kitty
       bindsym $mod+Return exec $term

       # Flameshot (XWayland) bindings
       bindsym Print exec "flameshot gui"
       bindsym Shift+Print exec "flameshot full -p ~/Pictures"
       bindsym Ctrl+Print exec "flameshot gui -c"

       # Autostart Flameshot
       exec --no-startup-id flameshot

     Optional native Wayland fallback (if you installed grim/slurp):
       bindsym $mod+Print exec "grim -g \"$(slurp)\" - | wl-copy"

  5) Log out or reboot into Sway (greetd/tuigreet is installed and enabled).

Notes:
  - Flameshot runs via XWayland; for most setups this works great. If you later
    want pixel-perfect Wayland-native capture, install 'grim' and 'slurp' and
    bind them separately as shown above.
EONEXT
