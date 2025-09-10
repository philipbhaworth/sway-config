#!/bin/bash

# Clipboard script using clipman
if ! command -v clipman &> /dev/null; then
    notify-send "Error" "clipman not found"
    exit 1
fi

# Use clipman with wofi
clipman pick --tool wofi --max-items 20