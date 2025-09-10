#!/bin/bash
entries="⇠ Logout\n⏾ Suspend\n⭮ Reboot\n⏻ Shutdown\n🔒 Lock"
selected=$(echo -e $entries | rofi -dmenu -p "Power" -theme-str 'window {width: 250px; height: 262px;}' | awk '{print tolower($2)}')

case $selected in
    logout)
        swaymsg exit;;
    suspend)
        exec systemctl suspend;;
    reboot)
        exec systemctl reboot;;
    shutdown)
        exec systemctl poweroff -i;;
    lock)
        exec swaylock;;
esac
