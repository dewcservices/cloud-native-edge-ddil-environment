# Network Impairment Gateway with Rancher and Kind Cluster

This setup deploys a Rancher server and a `kind` Kubernetes cluster using Docker Compose, along with a Network Impairment Gateway. The Rancher server will manage the `kind` Kubernetes cluster, and the impairment gateway provides an API and a UI for controlling network impairments between them.

## Operating System Dependencies:

- network emulation (netem) enabled within the kernel
- sufficient permissions to execute docker with NET_ADMIN privileges 
- docker, docker-compose, iptables, ip, ifconfig, and modprobe

### Install Kind

[installing-from-release-binaries](https://kind.sigs.k8s.io/docs/user/quick-start#installing-from-release-binaries)

Download and install kind using the following command:

```sh
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Install kubectl

Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

Kubernetes cli for interacting with the kind cluster

```sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo ln -s /usr/local/bin/kubectl /usr/bin/kubectl
```

**Recommendations**: To assist with establishing operating system requirements an oracle linux 8 vm can be initialised with the cloud-init provided [network-impairment-gateway-cloud-init.yaml](../oci-test-environment/network-impairment-gateway-cloud-init.yaml)

## Services Overview

### 1. `rancher`
- **Image**: `rancher/rancher:latest`
- **Role**: Rancher server for managing Kubernetes clusters.
- **Configuration**:
  - Runs in privileged mode and restarts automatically on failure.
  - Configures the default gateway to route traffic through the impairment gateway at `172.18.0.3`.
  - Starts Rancher without certificate checks (`--no-cacerts`).
- **Ports**:
  - `8081`: HTTP access to Rancher.
  - `8443`: HTTPS access to Rancher.
- **Network**: Connected to `network_cloud` with IP `172.18.0.2`.

### 2. `impairment_gateway`
- **Image**: `dewcservices/network-impairment-gateway`
- **Role**: Acts as the impairment gateway between `network_cloud` and `network_edge`.
- **Configuration**:
  - Runs in privileged mode with `NET_ADMIN` capabilities for network management.
  - Listens on port `8000` for API requests to configure impairments.
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
- **Dependencies**: Depends on the `rancher` container.

### 3. `impairment_gateway_ui`
- **Image**: `dewcservices/network-impairment-gateway-ui`
- **Role**: User interface for configuring and monitoring network impairments on the impairment gateway.
- **Configuration**:
  - Runs on port `8080`.
  - Environment variables:
    - `API_HOST`: Set to `http://localhost:8000` for impairment gateway API access.
    - `WEBSOCKET_HOST`: Set to `ws://localhost:8000` for live updates from impairment gateway.
- **Dependency**: Depends on the `impairment_gateway`.

### 4. `kind`
- uses kind cli

## Network Configuration

Two bridge networks are defined:
- **`network_cloud`**: `172.18.0.0/16` subnet.
- **`network_edge`**: `172.19.0.0/16` subnet.

Each container has a specific IP address, allowing for controlled routing and network impairments between the cloud and edge environments.

## Running the Setup

To launch the services, run:

```bash
sudo docker-compose up -d
```

This command will start all services in the background. Access the services at the following endpoints:

Rancher: http://localhost:8081 (HTTP) or https://localhost:8443 (HTTPS)
Impairment Gateway API: http://localhost:8000
Impairment Gateway UI: http://localhost:8080

## Access Rancher

1. Open Rancher at https://localhost:8443 (or the IP address of your Docker host).
2. Follow the setup instructions to create an admin password.

## Configure the Kind Cluster

1. Create a kind cluster with a specific configuration file (kind-config.yaml):

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
```

2. Run the command to create the kind cluster:

```sh
kind create cluster --name rancher-managed --config kind-cluster-config.yaml
```

3. Export the kubeconfig to allow Rancher to register the kind cluster:

```sh
export KUBECONFIG="$(kind get kubeconfig-path --name="kind-cluster")"
```

4. Copy the kubeconfig file to the kind_cluster container:

```sh
docker cp $(kind get kubeconfig-path --name="kind-cluster") kind_cluster:/root/.kube/config
```

## Register the Kind Cluster in Rancher

1. In the Rancher UI, go to Cluster Management > Create and select Import an Existing Cluster.

2. Follow the instructions to generate a command for importing the cluster.

3. Run the provided command inside the kind_cluster container.

```sh
docker exec -it kind_cluster <import_command>
```
4. Wait for the kind cluster to appear in Rancher as a managed cluster.

## Verify the Setup

1. Check the logs to ensure all services are running as expected:

```sh
docker logs rancher
docker logs kind_cluster
docker logs impairment_gateway
```

2. Access Rancher UI to view and manage the kind Kubernetes cluster.

## Clean Up

To stop and remove all containers, run:

```sh
docker-compose down
```
