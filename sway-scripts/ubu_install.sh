#!/usr/bin/env bash
# package_checker.sh
# Check which packages from your install script are actually installed

set -euo pipefail

# ----- Config: which user to check user services for -------------------------
TARGET_USER="${SUDO_USER:-$USER}"

# ----- Colors ----------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

echo -e "${BLUE}Package Installation Status Check${NC}"
echo "=================================="

# ----- Helper: test if any of the alternatives is installed ------------------
# Accepts entries like: "firefox-esr|firefox" or "sway-notification-center|swaynotificationcenter"
is_installed() {
  local spec="$1"
  local IFS='|'
  read -r -a ALTS <<< "$spec"
  for alt in "${ALTS[@]}"; do
    if dpkg-query -W -f='${Status}' "$alt" 2>/dev/null | grep -q "install ok installed"; then
      return 0
    fi
  done
  return 1
}

# Pretty printer
check_package() {
  local spec="$1"
  if is_installed "$spec"; then
    echo -e "${GREEN}✓${NC} $spec"
    return 0
  else
    echo -e "${RED}✗${NC} $spec"
    return 1
  fi
}

check_package_group() {
  local group_name="$1"; shift
  local packages=("$@")
  local missing=()

  echo -e "\n${BLUE}=== $group_name ===${NC}"
  for p in "${packages[@]}"; do
    if ! check_package "$p"; then
      missing+=("$p")
    fi
  done

  if ((${#missing[@]} > 0)); then
    echo -e "${YELLOW}Missing ${#missing[@]} packages from $group_name${NC}"
    return 1
  else
    echo -e "${GREEN}All packages installed for $group_name${NC}"
    return 0
  fi
}

# Generate install commands for missing packages; pick the first available alt
generate_install_commands() {
  local group_name="$1"; shift
  local packages=("$@")
  local to_install=()

  for spec in "${packages[@]}"; do
    if is_installed "$spec"; then
      continue
    fi
    local chosen=""
    IFS='|' read -r -a ALTS <<< "$spec"
    for alt in "${ALTS[@]}"; do
      if apt-cache policy "$alt" >/dev/null 2>&1 && apt-cache policy "$alt" | grep -q 'Candidate:'; then
        if ! apt-cache policy "$alt" | grep -q 'Candidate: (none)'; then
          chosen="$alt"; break
        fi
      fi
    done
    [[ -z "$chosen" ]] && chosen="${ALTS[0]}"
    to_install+=("$chosen")
  done

  if ((${#to_install[@]} > 0)); then
    echo -e "\n${YELLOW}To install missing $group_name packages:${NC}"
    echo "sudo apt install -y ${to_install[*]}"
  fi
}

# ----- Package groups (with sensible alternates) ------------------------------
BASE_PKGS=(
  build-essential git curl wget unzip p7zip-full
  htop vim tmux stow tree jq fzf ripgrep bat fd-find
  "firefox-esr|firefox"
)

# Prefer Flameshot; leave grim/slurp if you also want native Wayland capture
SWAY_WAYLAND_PKGS=(
  sway swaylock swayidle swaybg waybar wl-clipboard xwayland
  "flameshot|grim"
  slurp
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

# sway-notification-center package name may vary
AUDIO_NOTIFY_PKGS=(
  pipewire pipewire-audio wireplumber libspa-0.2-bluetooth
  alsa-utils "sway-notification-center|swaynotificationcenter"
  pavucontrol
  libnotify-bin
)

BLUETOOTH_PKGS=( bluez blueman )
NETWORK_PKGS=( network-manager )
POLKIT_PKGS=( lxqt-policykit )
MEDIA_PKGS=( qimgv mpv )
POWER_QOL_PKGS=( brightnessctl gammastep )
GREETER_PKGS=( greetd tuigreet )

EXTRA_CONFIG_TOOLS=( wofi wlogout swappy cliphist hyprpicker )

# Additional suggestions
MISSING_COMMON_PKGS=( pwvucontrol )

# ----- Checks ----------------------------------------------------------------
check_package_group "Base Packages" "${BASE_PKGS[@]}"
check_package_group "Sway/Wayland" "${SWAY_WAYLAND_PKGS[@]}"
check_package_group "Desktop Portals" "${PORTAL_PKGS[@]}"
check_package_group "Terminal/Editor" "${TERM_EDITOR_PKGS[@]}"
check_package_group "Files/Storage" "${FILES_STORAGE_PKGS[@]}"
check_package_group "Fonts/Themes" "${FONTS_THEME_PKGS[@]}"
check_package_group "Audio/Notifications" "${AUDIO_NOTIFY_PKGS[@]}"
check_package_group "Bluetooth" "${BLUETOOTH_PKGS[@]}"
check_package_group "Network" "${NETWORK_PKGS[@]}"
check_package_group "Polkit" "${POLKIT_PKGS[@]}"
check_package_group "Media" "${MEDIA_PKGS[@]}"
check_package_group "Power/QOL" "${POWER_QOL_PKGS[@]}"
check_package_group "Greeter" "${GREETER_PKGS[@]}"
check_package_group "Extra Tools" "${EXTRA_CONFIG_TOOLS[@]}"
check_package_group "Additional Useful" "${MISSING_COMMON_PKGS[@]}"

echo -e "\n${BLUE}=== INSTALL COMMANDS FOR MISSING PACKAGES ===${NC}"
generate_install_commands "Base Packages" "${BASE_PKGS[@]}"
generate_install_commands "Sway/Wayland" "${SWAY_WAYLAND_PKGS[@]}"
generate_install_commands "Desktop Portals" "${PORTAL_PKGS[@]}"
generate_install_commands "Terminal/Editor" "${TERM_EDITOR_PKGS[@]}"
generate_install_commands "Files/Storage" "${FILES_STORAGE_PKGS[@]}"
generate_install_commands "Fonts/Themes" "${FONTS_THEME_PKGS[@]}"
generate_install_commands "Audio/Notifications" "${AUDIO_NOTIFY_PKGS[@]}"
generate_install_commands "Bluetooth" "${BLUETOOTH_PKGS[@]}"
generate_install_commands "Network" "${NETWORK_PKGS[@]}"
generate_install_commands "Polkit" "${POLKIT_PKGS[@]}"
generate_install_commands "Media" "${MEDIA_PKGS[@]}"
generate_install_commands "Power/QOL" "${POWER_QOL_PKGS[@]}"
generate_install_commands "Greeter" "${GREETER_PKGS[@]}"
generate_install_commands "Extra Tools" "${EXTRA_CONFIG_TOOLS[@]}"
generate_install_commands "Additional Useful" "${MISSING_COMMON_PKGS[@]}"

# ----- Services --------------------------------------------------------------
echo -e "\n${BLUE}=== SERVICES STATUS (system) ===${NC}"
services=("NetworkManager" "bluetooth" "greetd")
for service in "${services[@]}"; do
  if systemctl is-enabled "$service" >/dev/null 2>&1; then
    if systemctl is-active "$service" >/dev/null 2>&1; then
      echo -e "${GREEN}✓${NC} $service (enabled and running)"
    else
      echo -e "${YELLOW}!${NC} $service (enabled but not running)"
    fi
  else
    echo -e "${RED}✗${NC} $service (not enabled)"
  fi
done

# PipeWire/WirePlumber are user services; check for the desktop user, not root.
echo -e "\n${BLUE}=== AUDIO SYSTEM CHECK (user: $TARGET_USER) ===${NC}"
user_services=("pipewire" "pipewire-pulse" "wireplumber")
for service in "${user_services[@]}"; do
  if sudo -u "$TARGET_USER" systemctl --user is-active "$service" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $service (running)"
  else
    echo -e "${RED}✗${NC} $service (not running)"
  fi
done

echo -e "\n${YELLOW}Tip:${NC} If user services don't start outside a login session, consider:"
echo "  loginctl enable-linger $TARGET_USER"
echo "  # Then log out/in or start a proper user session (e.g., Sway or a DM)."

echo -e "\n${YELLOW}Audio controls you may want installed:${NC}"
echo "sudo apt install -y pavucontrol pwvucontrol"
