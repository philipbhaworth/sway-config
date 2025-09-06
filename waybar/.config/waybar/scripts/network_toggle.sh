#!/bin/bash

# Network toggle script - switches between "ethernet" and IP address
STATE_FILE="/tmp/waybar_network_state"

# Get current IP address
get_ip() {
  ip route get 1.1.1.1 | awk '{print $7; exit}' 2>/dev/null || echo "No IP"
}

# Check current state
if [ -f "$STATE_FILE" ]; then
  current_state=$(cat "$STATE_FILE")
else
  current_state="label"
fi

# Toggle state and output
if [ "$current_state" = "label" ]; then
  # Show IP address
  ip_addr=$(get_ip)
  echo "ip" >"$STATE_FILE"
  echo "$ip_addr"
else
  # Show ethernet label
  echo "label" >"$STATE_FILE"
  echo "ethernet"
fi
