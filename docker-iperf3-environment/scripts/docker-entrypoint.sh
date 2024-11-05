#!/bin/sh
# Delete the existing default route and set the new gateway
set -e

# Set the default gateway if specified
if [ -n "$DEFAULT_GATEWAY" ]; then
  ip route del default
  ip route add default via "$DEFAULT_GATEWAY"
fi

# Execute the passed command, whether it's iperf3 server or client
exec "$@"