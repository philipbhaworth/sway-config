#!/usr/bin/env bash
# ~/.config/sway/scripts/powermenu.sh

set -u

# Prefer rofi-wayland if available; fall back to rofi.
ROFI_BIN="$(command -v rofi-wayland || command -v rofi)"
[ -n "${ROFI_BIN}" ] || {
  notify-send "Rofi not found"
  exit 1
}

# Optional: point to your theme; remove -theme flag if you don't use one.
ROFI_THEME="${HOME}/.config/rofi/themes/flexoki-dark-gray.rasi"
THEME_FLAG=()
[ -f "$ROFI_THEME" ] && THEME_FLAG=(-theme "$ROFI_THEME")

# Menu entries (no icons)
OPTIONS=(
  "Shutdown"
  "Reboot"
  "Suspend"
  "Lock"
  "Logout"
)

# Show menu
CHOICE="$(
  printf '%s\n' "${OPTIONS[@]}" |
    "${ROFI_BIN}" -dmenu -i \
      -p "Power Menu" \
      -lines 5 \
      -width 30 \
      -no-custom \
      "${THEME_FLAG[@]}" 2>/dev/null
)"

# If user cancelled
[ -z "${CHOICE}" ] && exit 1

case "${CHOICE}" in
"Shutdown")
  systemctl poweroff
  ;;
"Reboot")
  systemctl reboot
  ;;
"Suspend")
  systemctl suspend
  ;;
"Lock")
  swaylock -f \
    --image "${HOME}/wallpapers/wall72.png" \
    --color 100f0f \
    --inside-color 282726 \
    --inside-clear-color 24837b \
    --inside-ver-color ad8301 \
    --inside-wrong-color af3029 \
    --ring-color cecdc3 \
    --ring-clear-color 24837b \
    --ring-ver-color ad8301 \
    --ring-wrong-color af3029 \
    --key-hl-color 24837b \
    --bs-hl-color af3029 \
    --separator-color 100f0f \
    --text-color cecdc3 \
    --text-clear-color cecdc3 \
    --text-ver-color cecdc3 \
    --text-wrong-color cecdc3 \
    --indicator-radius 100 \
    --indicator-thickness 10 \
    --font "JetBrainsMono Nerd Font"
  ;;
"Logout")
  swaymsg exit
  ;;
*)
  exit 1
  ;;
esac
