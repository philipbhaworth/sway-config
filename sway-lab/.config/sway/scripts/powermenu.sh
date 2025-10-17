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
        swaylock -f \
            --image ~/wallpapers/wallpapers/wall72.png \
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
    logout)
        swaymsg exit
        ;;
esac
