#!/bin/bash
output="$HOME/Pictures/screenshots/shot_$(date +"%Y-%m-%d-%H-%M-%S").png"
mkdir -p "$HOME/Pictures/screenshots"

pkill grim
pkill slurp

if [ "$1" = "region" ]; then
    if grim -g "$(slurp)" - | tee "$output" | wl-copy && swappy -f "$output"; then
        notify-send "Screenshot saved" "$output"
    else
        notify-send "Screenshot cancelled"
        exit 1
    fi
fi

if [ "$1" = "full" ]; then
    if grim "$output"; then
        wl-copy < "$output"
        notify-send "Screenshot saved" "$output"
    else
        notify-send "Screenshot cancelled"
        exit 1
    fi
fi
