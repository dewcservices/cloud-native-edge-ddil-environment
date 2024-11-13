# Network Impairment Gateway with iperf3 Containers

This setup includes three primary services:
- **iperf3_cloud**: Acts as the cloud-side endpoint.
- **iperf3_edge**: Acts as the edge-side endpoint.
- **impairment_gateway**: A network impairment gateway that applies impairments between the `iperf3_cloud` and `iperf3_edge` containers.
- **impairment_gateway UI**: Web UI for controlling the network impairment gateway.

## Usage

### Prerequisites
- Ensure Docker and Docker Compose are installed on your system.

### Getting Started

1. **Clone the repository** (if applicable):

```sh
git clone https://github.com/dewcservices/cloud-native-edge-ddil-environment
cd network-impairment-gateway
cd docker-iperf3-environment
```

2. Start the Docker Compose setup:

```sh
docker-compose -f docker-compose.yaml up -d
```

NOTE: if you are making changes to the iperf3 dockerfile the following is convinient

```sh
docker-compose -f docker-compose.yaml up -d --build --force-recreate
```

3. Verify Container Status:

To check if all services are running, use:

```sh
docker ps
```
4. Running Tests with iperf3:

- iperf3 has been set to run in server mode on both iperf3_cloud and iperf3_edge.
- You can run tests by connecting to one of the containers and executing iperf3 in client mode to test network performance across the impairment gateway.

Example:
```sh
docker exec -it iperf3_edge iperf3 -c 172.18.0.2 -t 240
```

This command tests network performance between the iperf3_edge (client) and iperf3_cloud (server) containers.

## Impairment Gateway

The impairment_gateway container sits between iperf3_cloud and iperf3_edge to simulate network impairments. The gateway's IP settings and configuration allow it to apply traffic control rules between the cloud and edge networks.

### Environment Variables

- UPLINK_INTERFACE: The uplink interface for cloud traffic.
- DOWNLINK_INTERFACE: The downlink interface for edge traffic.
- MOCK_PROCESS_CALLS: Set to FALSE to disable mock calls.
- DATABASE_SEEDED: Set to FALSE to disable auto-seeding.
- CORS_ORIGINS: hostname of the impairment gateway ui.

### Accessing the Impairment Gateway UI
The impairment gateway’s interface can be accessed at http://localhost:8080.

### Stopping the Environment

To stop and remove all services, run:

```sh
docker-compose -f docker-compose.yaml down
```
### Troubleshooting
If there are issues with network routes or impairments, check the logs for each container:

```sh
docker logs <container_name>
```

For example:
```sh
docker logs impairment_gateway
```

# Notes

- iperf3 has been configured to remove the default gateway and add a custom gateway route through the impairment_gateway for testing impaired network conditions.
- Ensure NET_ADMIN capabilities are granted, as they are required for network route modifications in containers