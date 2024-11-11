1. Enable IP Forwarding on Network Impairment Gateway VM:

Ensure that IP forwarding is enabled on Network Impairment Gateway VM so it can forward packets between Cloud and Edge. On Linux, you can enable IP forwarding with:

```sh
sudo sysctl -w net.ipv4.ip_forward=1
```

2. Configure Routing on Cloud VM:

Update the routing table on Cloud VM to send traffic destined for Edge VM's IP through NIG VM. You can add a route on Cloud VM like this:
```sh
sudo ip route add <EDGE_IP> via <NIG_IP>
```

3. Configure Routing on Edge VM (if necessary):

Ensure that Edge VM knows to route return traffic to Cloud VM via NIG VM. This may involve adding a route on Edge VM:
```sh
sudo ip route add <CLOUD_IP> via <NIG_IP>
```

sudo ip route add 10.0.0.147 via 10.0.0.36

sudo ip route add 10.0.0.24 via 10.0.0.36


sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT




