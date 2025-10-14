#!/bin/bash
# ~/.config/sway/scripts/powermenu.sh

entries="⏻  Shutdown\n⭮ Reboot\n⏾ Suspend\n🔒 Lock\n⇠ Logout"

selected=$(echo -e "$entries" | wofi --dmenu \
    --prompt "Power Menu" \
    --width 250 \
    --height 210 \
    --cache-file /dev/null \
    | awk '{print tolower($2)}')

case $selected in
    shutdown)
        systemctl poweroff
        ;;
    reboot)
        systemctl reboot
        ;;
    suspend)
        systemctl suspend
        ;;
    lock)
        swaylock -f
        ;;
    logout)
        swaymsg exit
        ;;
esac
