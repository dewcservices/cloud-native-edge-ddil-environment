# Network Impairment Gateway with iPerf3 Cloud and Edge Containers

This setup uses Docker containers to simulate a cloud and edge environment connected by a network impairment gateway. The impairment gateway allows testing of various network conditions between the `iperf3_cloud` and `iperf3_edge` containers using the iPerf3 tool for network performance measurements.

For more details on [iperf3](https://github.com/esnet/iperf).


# Docker Configuration Diagram

This ASCII diagram represents the Docker configuration for iPerf3 cloud and edge containers connected by a network impairment gateway. The setup includes two networks, `network_cloud` and `network_edge`, with an impairment gateway managing traffic between them.

```plaintext
                          +----------------------------+
                          |        iperf3_cloud        |
                          |      (iPerf3 Server)       |
                          |                            |
                          |     IP: 172.18.0.2         |
                          |  Network: network_cloud    |
                          +----------------------------+
                                      |
                                      |
                    +-----------------+-----------------+
                    |    network_cloud (172.18.0.0/16)  |
                    |                                   |
            +-------+--------+----------------+--------+-------+
            |                impairment                        |
            |                  gateway                         |
            | IP: 172.18.0.3                    IP: 172.19.0.3 |
            | (network_cloud)                   (network_edge) |
            +----------------+----------------+----------------+
                    |                                    |
                    |     network_edge (172.19.0.0/16)   |
                    +------------------------------------+
                                        |
                                        |
                          +----------------------------+
                          |        iperf3_edge         |
                          |      (iPerf3 Client)       |
                          |                            |
                          |     IP: 172.19.0.2         |
                          |  Network: network_edge     |
                          +----------------------------+
```

## Operating System Dependencies:

- network emulation (netem) enabled within the kernel
- sufficient permissions to execute docker with NET_ADMIN privileges 
- docker, docker-compose, iptables, ip, ifconfig, and modprobe

**Recommendations**: To assist with establishing operating system requirements an oracle linux 8 vm can be initialised with the cloud-init provided [network-impairment-gateway-cloud-init.yaml](../oci-test-environment/network-impairment-gateway-cloud-init.yaml)

## Services Overview

### 1. `iperf3_cloud`
- **Role**: Acts as the iPerf3 server in the cloud network.
- **Build**: Built from the local Dockerfile in the project directory.
- **Configuration**:
  - Sets the subnet gateway to the impairment gateway's IP (`172.18.0.3`).
  - Runs iPerf3 in server mode, listening for connections.
- **Network**: Connected to `network_cloud` with IP `172.18.0.2`.

### 2. `iperf3_edge`
- **Role**: Represents the iPerf3 client in the edge network.
- **Build**: Built from the local Dockerfile in the project directory.
- **Configuration**:
  - Sets the subnet gateway to the impairment gateway's IP (`172.19.0.3`).
  - Runs a command to keep the container active (useful for executing iPerf3 client commands manually within the container).
- **Network**: Connected to `network_edge` with IP `172.19.0.2`.

### 3. `impairment_gateway`
- **Image**: `dewcservices/network-impairment-gateway:1.1.3`
- **Role**: Acts as the network impairment gateway, controlling the flow between `iperf3_cloud` and `iperf3_edge`.
- **Configuration**:
  - Runs in privileged mode with `NET_ADMIN` capabilities to modify network settings.
  - Listens on port `8000` for configuration and API requests.
  - Environment variables:
    - `UPLINK_INTERFACE`: Interface for uplink traffic (default: `eth0`).
    - `DOWNLINK_INTERFACE`: Interface for downlink traffic (default: `eth1`).
    - `MOCK_PROCESS_CALLS`:
        - `FALSE` for real impairments set
        - `True` impairment commands are printed to terminal only.
    - `DATABASE_SEEDED`: Boolean
        - `FALSE` seeds the network impairment gateway sqlite db.
        - `True` network impairment gateway sqlite db already seeded.
    - `CORS_ORIGINS`: Set to allow requests from the user interface `http://localhost:8080`.

- **Networks**:
  - Connected to both `network_cloud` (`172.18.0.3`) and `network_edge` (`172.19.0.3`).
- **Dependencies**: Requires `iperf3_cloud` and `iperf3_edge` to be running.

### 4. `impairment_gateway_ui`
- **Image**: `dewcservices/network-impairment-gateway-ui:1.0.5`
- **Role**: Provides a UI for configuring and monitoring the impairment gateway.
- **Configuration**:
  - Runs on port `8080`.
  - Environment variables:
    - `API_HOST`: Set to `http://localhost:8000` for the impairment gateway API.
    - `WEBSOCKET_HOST`: Set to `ws://localhost:8000` for WebSocket live updates.
- **Dependency**: Requires `impairment_gateway` to be running.

## Network Configuration

Two bridge networks are configured:
- **`network_cloud`**: `172.18.0.0/16` subnet.
- **`network_edge`**: `172.19.0.0/16` subnet.

Each container has a unique IP address within its respective subnet, allowing network traffic control between the cloud and edge.

## Running the Setup

To launch the services, execute:

```bash
docker-compose up -d
```

This command will start all services in the background. The impairment gateway's API will be accessible at http://localhost:8000, and the UI will be accessible at http://localhost:8080.

**NOTE**: if you are making changes to the iperf3 dockerfile the following is convinient

```sh
docker-compose -f docker-compose.yaml up -d --build --force-recreate
```

## Clean Up

To stop and remove all containers, run:

```sh
docker-compose down
```

## Additional Notes
### iPerf3 Testing:

Once the setup is running, you can use iperf3 from within iperf3_edge to connect to the iperf3_cloud server, allowing you to test network performance across the impairment gateway.

Example command from within the iperf3_edge container:
```sh
iperf3 -c 172.18.0.2 -t 240
```

### Impairment Configuration: 

The impairment gateway can be configured via its API or UI to simulate various network impairments (e.g., latency, packet loss) and observe their impact on iPerf3 measurements. 

To add new bearers or environment profiles please refer to the [network impairment gateway](https://github.com/dewcservices/network-impairment-gateway)
