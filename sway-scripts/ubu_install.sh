#!/usr/bin/env bash
# install.sh
# Debian 13 (trixie) / Ubuntu 22.04 (jammy) / 24.04 (noble)
# Minimal Sway + Wayland tooling installer (no config writes), with Flameshot/Kitty.
# Notes:
# - No grim/slurp (you requested Flameshot). Keep xwayland for Flameshot.
# - Handles package naming differences across Debian/Ubuntu.
# - Tries both "sway-notification-center" and "swaynotificationcenter".
# - Does not write user configs; assumes dotfiles.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
USER_NAME="${SUDO_USER:-${USER}}"

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (e.g.,: sudo $0)"; exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  echo "apt-get not found; this script targets Debian/Ubuntu."; exit 1
fi

# Detect distro/codename
# shellcheck disable=SC1091
. /etc/os-release
DISTRO_ID="${ID:-}"
CODENAME="${VERSION_CODENAME:-}"

echo "==> Detected: ID=${DISTRO_ID}, CODENAME=${CODENAME}"

apt_install() {
  apt-get update
  apt-get install -y --no-install-recommends "$@"
}

pkg_available() {
  # Returns 0 if candidate exists, otherwise 1
  local pkg="$1"
  # apt-cache policy returns "Candidate: (none)" when missing
  local cand
  cand="$(apt-cache policy "$pkg" | awk -F': ' '/Candidate:/ {print $2}' | head -n1 || true)"
  [[ -n "${cand:-}" && "${cand}" != "(none)" ]]
}

install_if_available() {
  # Installs only the packages that exist; prints warnings for missing
  local want=("$@")
  local have=()
  local miss=()
  for p in "${want[@]}"; do
    if pkg_available "$p"; then
      have+=("$p")
    else
      miss+=("$p")
    fi
  done
  if [[ ${#have[@]} -gt 0 ]]; then
    echo "==> Installing ${#have[@]} packages..."
    apt_install "${have[@]}"
  fi
  if [[ ${#miss[@]} -gt 0 ]]; then
    echo "==> Skipping unavailable packages: ${miss[*]}"
  fi
}

# ---------------- Package sets (common) ----------------
BASE_PKGS=(
  build-essential git curl wget unzip p7zip-full
  htop vim tmux stow tree jq fzf ripgrep bat fd-find
)

# Browser differs: Debian has firefox-esr; Ubuntu typically "firefox" (Snap-backed)
DEBIAN_BROWSER=( firefox-esr )
UBUNTU_BROWSER=( firefox )

SWAY_WAYLAND_PKGS=(
  sway swaylock swayidle swaybg waybar
  wl-clipboard xwayland
  # NOTE: grim/slurp intentionally omitted (Flameshot chosen)
)

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

# Audio differs: Debian metapkg "pipewire-audio"; Ubuntu uses "pipewire-pulse"
DEBIAN_AUDIO_PKGS=( pipewire pipewire-audio wireplumber )
UBUNTU_AUDIO_PKGS=( pipewire pipewire-pulse wireplumber )

AUDIO_COMMON_PKGS=(
  libspa-0.2-bluetooth
  alsa-utils
  pavucontrol
  libnotify-bin
)

# sway-notification-center package name varies by repo; we’ll try both.
SWAYNC_NAMES=( sway-notification-center swaynotificationcenter )

BLUETOOTH_PKGS=( bluez blueman )
NETWORK_PKGS=( network-manager )
POLKIT_PKGS=( lxqt-policykit )
MEDIA_PKGS=( qimgv mpv )
POWER_QOL_PKGS=( brightnessctl gammastep )

LAUNCHER_UTIL_PKGS=(
  wofi
  wlogout
  swappy
  cliphist
  flameshot   # Your chosen screenshot tool
)

GREETER_PKGS=( greetd tuigreet )
EXTRA_RUNTIME_PKGS=( seatd ) # Helpful when running compositors without a full DM

# ---------------- Build final package list by distro ----------------
ALL_PKGS=(
  "${BASE_PKGS[@]}"
  "${SWAY_WAYLAND_PKGS[@]}"
  "${PORTAL_PKGS[@]}"
  "${TERM_EDITOR_PKGS[@]}"
  "${FILES_STORAGE_PKGS[@]}"
  "${FONTS_THEME_PKGS[@]}"
  "${BLUETOOTH_PKGS[@]}"
  "${NETWORK_PKGS[@]}"
  "${POLKIT_PKGS[@]}"
  "${MEDIA_PKGS[@]}"
  "${POWER_QOL_PKGS[@]}"
  "${LAUNCHER_UTIL_PKGS[@]}"
  "${GREETER_PKGS[@]}"
  "${EXTRA_RUNTIME_PKGS[@]}"
)

case "${DISTRO_ID}" in
  debian)
    ALL_PKGS+=( "${DEBIAN_BROWSER[@]}" )
    ALL_PKGS+=( "${DEBIAN_AUDIO_PKGS[@]}" )
    ALL_PKGS+=( "${AUDIO_COMMON_PKGS[@]}" )
    ;;
  ubuntu)
    ALL_PKGS+=( "${UBUNTU_BROWSER[@]}" )
    ALL_PKGS+=( "${UBUNTU_AUDIO_PKGS[@]}" )
    ALL_PKGS+=( "${AUDIO_COMMON_PKGS[@]}" )
    ;;
  *)
    echo "Warning: unrecognized distro ID '${DISTRO_ID}'. Proceeding with Debian-like defaults."
    ALL_PKGS+=( "${DEBIAN_BROWSER[@]}" )
    ALL_PKGS+=( "${DEBIAN_AUDIO_PKGS[@]}" )
    ALL_PKGS+=( "${AUDIO_COMMON_PKGS[@]}" )
    ;;
esac

echo "==> Installing core package sets (this may take a while)..."
install_if_available "${ALL_PKGS[@]}"

# Try sway-notification-center under either common name
for swync in "${SWAYNC_NAMES[@]}"; do
  if pkg_available "$swync"; then
    echo "==> Installing notification daemon: $swync"
    apt_install "$swync"
    break
  fi
done

# ---------------- Enable core services ----------------
echo "==> Enabling services..."
systemctl enable --now NetworkManager || true
systemctl enable --now bluetooth || true
systemctl enable --now greetd || true

# seatd helps when not running a full display manager
systemctl enable --now seatd || true
# Add the main user to common input/video seats so rootless compositors work better
for grp in video input seatd; do
  if getent group "$grp" >/dev/null; then
    usermod -aG "$grp" "$USER_NAME" || true
  fi
done

# PipeWire/WirePlumber are user units; they’ll auto-start on demand.
# If you want to force-enable for the current user later:
#   systemctl --user enable --now pipewire pipewire-pulse wireplumber

# ---------------- Flatpak: add Flathub (if flatpak exists) -------------
if command -v flatpak >/dev/null 2>&1; then
  if ! sudo -u "$USER_NAME" flatpak remotes | grep -q '^flathub'; then
    echo "==> Adding Flathub remote for user: $USER_NAME"
    sudo -u "$USER_NAME" flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
fi

cat <<'EONEXT'
==> Install complete.

Next steps:
  1) (Optional) Convenience aliases on Ubuntu/Debian:
       echo "alias bat='batcat'" >> ~/.bashrc
       echo "alias fd='fdfind'"   >> ~/.bashrc

  2) Launch the browser to sign into services:
       firefox    # Debian uses ESR; Ubuntu installs Firefox (Snap-backed).

  3) Clone your dotfiles and stow configs (example):
       git clone git@github.com:<you>/<dotfiles>.git ~/.dotfiles
       cd ~/.dotfiles
       stow sway waybar foot kitty   # adjust to your repo layout

  4) Starting Sway
     - If using greetd/tuigreet (installed/enabled), log in via the greeter.
     - Or add this to ~/.bash_profile for TTY1 autostart:
         if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
           exec dbus-run-session -- sway
         fi

  5) Bind Flameshot + set Kitty in your Sway config (~/.config/sway/config):
       set $term kitty
       bindsym $mod+Return exec $term
       exec --no-startup-id flameshot
       bindsym Print        exec "flameshot gui"
       bindsym Shift+Print  exec "flameshot full -p ~/Pictures"
       bindsym Ctrl+Print   exec "flameshot gui -c"
       mkdir -p ~/Pictures

Notes:
  - grim/slurp omitted by request; Flameshot (via XWayland) is your screenshot tool.
  - If you ever need native Wayland capture, install grim slurp swappy and add separate binds.
  - On Ubuntu, audio stack is pipewire + pipewire-pulse + wireplumber.
  - On Debian, audio stack is pipewire + pipewire-audio + wireplumber.
EONEXT