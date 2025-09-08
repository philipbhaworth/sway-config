#!/usr/bin/env bash
# package_checker.sh
# Check which packages from your install script are actually installed

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Package arrays from your script
BASE_PKGS=(
  build-essential git curl wget unzip p7zip-full
  htop vim tmux stow tree jq fzf ripgrep bat fd-find
  firefox-esr
)

SWAY_WAYLAND_PKGS=(
  sway swaylock swayidle swaybg waybar wl-clipboard xwayland grim slurp
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
FONTS_THEME_PKGS=( fonts-dejavu fonts-noto fonts-noto-color-emoji fonts-font-awesome nwg-look )
AUDIO_NOTIFY_PKGS=( pipewire pipewire-audio wireplumber libspa-0.2-bluetooth alsa-utils sway-notification-center )
BLUETOOTH_PKGS=( bluez blueman )
NETWORK_PKGS=( network-manager )
POLKIT_PKGS=( lxqt-policykit )
MEDIA_PKGS=( qimgv mpv )
POWER_QOL_PKGS=( brightnessctl gammastep )
GREETER_PKGS=( greetd tuigreet )
EXTRA_CONFIG_TOOLS=( wofi swappy hyprpicker cliphist )

# Additional packages that might be useful
MISSING_COMMON_PKGS=( pavucontrol pwvucontrol wlogout mako )

check_package() {
    local pkg="$1"
    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        echo -e "${GREEN}✓${NC} $pkg"
        return 0
    else
        echo -e "${RED}✗${NC} $pkg"
        return 1
    fi
}

check_package_group() {
    local group_name="$1"
    shift
    local packages=("$@")
    local missing_count=0
    
    echo -e "\n${BLUE}=== $group_name ===${NC}"
    
    for pkg in "${packages[@]}"; do
        if ! check_package "$pkg"; then
            ((missing_count++))
        fi
    done
    
    if [ $missing_count -gt 0 ]; then
        echo -e "${YELLOW}Missing $missing_count packages from $group_name${NC}"
        return 1
    else
        echo -e "${GREEN}All packages installed for $group_name${NC}"
        return 0
    fi
}

generate_install_commands() {
    local group_name="$1"
    shift
    local packages=("$@")
    local missing_packages=()
    
    for pkg in "${packages[@]}"; do
        if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}To install missing $group_name packages:${NC}"
        echo "sudo apt install -y ${missing_packages[*]}"
    fi
}

echo -e "${BLUE}Package Installation Status Check${NC}"
echo "=================================="

# Check each group
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

# Generate install commands for missing packages
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

echo -e "\n${BLUE}=== SERVICES STATUS ===${NC}"
echo "Checking systemd services..."

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

echo -e "\n${BLUE}=== AUDIO SYSTEM CHECK ===${NC}"
echo "Checking PipeWire/WirePlumber status..."

# Check user services (PipeWire runs as user)
user_services=("pipewire" "pipewire-pulse" "wireplumber")
for service in "${user_services[@]}"; do
    if systemctl --user is-active "$service" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $service (running)"
    else
        echo -e "${RED}✗${NC} $service (not running)"
    fi
done

echo -e "\n${YELLOW}To fix your Waybar audio issue, you likely need:${NC}"
echo "sudo apt install -y pavucontrol pwvucontrol"
