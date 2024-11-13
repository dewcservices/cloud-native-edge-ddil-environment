# Network Impairment Gateway with Cloud and Edge Containers

This setup simulates a network impairment gateway connecting two subnets, `network_cloud` and `network_edge`. It uses Docker containers to represent the cloud and edge environments, with a central impairment gateway to control and test network conditions between the two networks.

```plaintext
                          +----------------------------+
                          |      container_cloud       |
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
                          |        container_edge      |
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

### 1. `container_cloud`
- **Image**: `busybox`
- **Role**: Simulates a cloud-based container.
- **Configuration**:
  - Runs a shell command to set the subnet gateway to the impairment gateway's IP (`172.18.0.3`).
  - Outputs `"container_cloud running"` every 5 seconds.
- **Network**: Connected to `network_cloud` with IP `172.18.0.2`.

### 2. `container_edge`
- **Image**: `busybox`
- **Role**: Simulates an edge device.
- **Configuration**:
  - Runs a shell command to set the subnet gateway to the impairment gateway's IP (`172.19.0.3`).
  - Outputs `"container_edge running"` every 5 seconds.
- **Network**: Connected to `network_edge` with IP `172.19.0.2`.

### 3. `impairment_gateway`
- **Image**: `dewcservices/network-impairment-gateway:latest`
- **Role**: Acts as the impairment gateway between `container_cloud` and `container_edge`.
- **Configuration**:
  - Runs in privileged mode with `NET_ADMIN` capabilities.
  - Listens on port `8000` for API and network configuration.
  - Environment variables for configuration:
    - `UPLINK_INTERFACE`: Interface for uplink traffic (default: `eth0`).
    - `DOWNLINK_INTERFACE`: Interface for downlink traffic (default: `eth1`).
    - `MOCK_PROCESS_CALLS`: Set to `FALSE` for real processing.
    - `DATABASE_SEEDED`: Set to `FALSE` if seeding is not required.
    - `CORS_ORIGINS`: Allowed CORS origins, set to `http://localhost:8081`.
- **Networks**:
  - Connected to both `network_cloud` (`172.18.0.3`) and `network_edge` (`172.19.0.3`).
- **Dependencies**: `container_cloud` and `container_edge`.

### 4. `impairment_gateway_ui`
- **Image**: `dewcservices/network-impairment-gateway-ui:latest`
- **Role**: Provides a user interface for controlling and monitoring the impairment gateway.
- **Configuration**:
  - Runs on port `8080`.
  - Environment variables:
    - `API_HOST`: API endpoint for the impairment gateway (`http://localhost:8002`).
    - `WEBSOCKET_HOST`: WebSocket endpoint for live updates (`ws://localhost:8002`).
- **Dependency**: `impairment_gateway`.

## Network Configuration

Two bridge networks are used to separate cloud and edge environments:
- **`network_cloud`**: `172.18.0.0/16` subnet.
- **`network_edge`**: `172.19.0.0/16` subnet.

Each container has a unique IP address within its respective subnet, allowing the impairment gateway to simulate various network conditions between the cloud and edge.

## Running the Setup

To launch the services, use:

```bash
docker-compose up -d
```

This command will start all services in the background. The impairment gateway will be accessible at http://localhost:8000, and the UI will be available at http://localhost:8080.

## Clean Up

To stop and remove all containers, run:

```sh
docker-compose down
```

# Additional Notes
Ensure Docker is installed and configured to allow privileged containers.
The impairment gateway can be configured via its API or the UI for testing various network impairments.