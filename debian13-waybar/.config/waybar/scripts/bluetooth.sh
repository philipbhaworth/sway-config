#!/bin/bash

# Bluetooth status and control script for waybar

get_bluetooth_status() {
    if ! systemctl is-active --quiet bluetooth; then
        echo ""  # Bluetooth service not running
        return
    fi
    
    # Check if bluetooth is powered on
    if bluetoothctl show | grep -q "Powered: yes"; then
        # Check for connected devices
        connected=$(bluetoothctl devices Connected | wc -l)
        if [ "$connected" -gt 0 ]; then
            echo ""  # Connected
        else
            echo ""    # On but no connections
        fi
    else
        echo ""     # Powered off
    fi
}

# If no arguments, just return status
if [ $# -eq 0 ]; then
    get_bluetooth_status
    exit 0
fi

# Handle click actions
case "$1" in
    "toggle")
        if bluetoothctl show | grep -q "Powered: yes"; then
            bluetoothctl power off
            notify-send "Bluetooth" "Turned off"
        else
            bluetoothctl power on
            notify-send "Bluetooth" "Turned on" 
        fi
        ;;
    "manager")
        if command -v blueman-manager &> /dev/null; then
            blueman-manager
        else
            notify-send "Bluetooth" "Install blueman for GUI manager"
        fi
        ;;
esac