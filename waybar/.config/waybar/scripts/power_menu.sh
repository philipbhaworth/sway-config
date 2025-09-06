#!/bin/bash

# Simple power menu using wofi
options="Shutdown\nReboot\nLogout\nLock\nCancel"

selected=$(echo -e "$options" | wofi --dmenu \
  --prompt "Power Menu" \
  --width 200 \
  --height 200 \
  --lines 5)

case $selected in
"Shutdown")
  systemctl poweroff
  ;;
"Reboot")
  systemctl reboot
  ;;
"Logout")
  swaymsg exit
  ;;
"Lock")
  swaylock
  ;;
"Cancel" | "")
  exit 0
  ;;
esac
