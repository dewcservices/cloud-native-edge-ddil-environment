#!/bin/bash

# Enable IP forwarding to allow traffic to pass through the gateway
sysctl -w net.ipv4.ip_forward=1

# Set up iptables rules to forward traffic between UPLINK_INTERFACE (cloud) and DOWNLINK_INTERFACE (edge)
iptables -A FORWARD -i "$UPLINK_INTERFACE" -o "$DOWNLINK_INTERFACE" -j ACCEPT
iptables -A FORWARD -i "$DOWNLINK_INTERFACE" -o "$UPLINK_INTERFACE" -j ACCEPT

# Enable NAT for outgoing packets from UPLINK_INTERFACE to DOWNLINK_INTERFACE and vice versa (optional, for proper routing)
iptables -t nat -A POSTROUTING -o "$DOWNLINK_INTERFACE" -j MASQUERADE
iptables -t nat -A POSTROUTING -o "$UPLINK_INTERFACE" -j MASQUERADE

# Start fastapi app with uvicorn
exec uvicorn app.main:app --host 0.0.0.0 --port 8000