# Network Impairment Gateway with Rancher and Kind Cluster

This setup deploys a Rancher server and a `kind` Kubernetes cluster using Docker Compose, along with a Network Impairment Gateway. The Rancher server will manage the `kind` Kubernetes cluster, and the impairment gateway will handle traffic between them.

## Prerequisites

1. **Docker**: Make sure Docker is installed and running.
2. **Kind CLI**: Install [Kind](https://kind.sigs.k8s.io/).
3. **Kubectl**: Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Setup Instructions

### Step 1: Clone Repository

Clone this repository to get the `docker-compose.yml` file and other setup scripts.

```bash
git clone https://github.com/dewcservices/cloud-native-edge-ddil-environment
cd network-impairment-gateway
cd docker-k8s-environment
```

### Step 2: Install Kind

[installing-from-release-binaries](https://kind.sigs.k8s.io/docs/user/quick-start#installing-from-release-binaries)

Download and install kind using the following command:


```sh
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Step 2: Start Docker Compose Services

Run the Docker Compose command to start Rancher, the kind cluster, and the impairment gateway.

```sh
sudo docker-compose -f docker-compose.yaml up -d
```

### Step 3: Access Rancher

1. Open Rancher at https://localhost:8443 (or the IP address of your Docker host).
2. Follow the setup instructions to create an admin password.

### Step 4: Configure the Kind Cluster

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

### Step 5: Register the Kind Cluster in Rancher

1. In the Rancher UI, go to Cluster Management > Create and select Import an Existing Cluster.

2. Follow the instructions to generate a command for importing the cluster.

3. Run the provided command inside the kind_cluster container.

```sh
docker exec -it kind_cluster <import_command>
```
4. Wait for the kind cluster to appear in Rancher as a managed cluster.

### Step 6: Verify the Setup

1. Check the logs to ensure all services are running as expected:

```sh
docker logs rancher
docker logs kind_cluster
docker logs impairment_gateway
```

2. Access Rancher UI to view and manage the kind Kubernetes cluster.

### Step 7: Clean Up

To stop and remove all containers, run:

```sh
docker-compose down
```

# Notes

- Network Impairment Gateway: Configure impairments as needed in the Rancher-managed kind cluster. Use the network-impairment-gateway to simulate network issues.
- Default Credentials: Rancher initially sets up with default credentials. Update passwords for security.
- Ports: Rancher uses ports 8080 and 8443 (HTTPS), and the impairment gateway uses 8000. Adjust these as necessary.

Now, you have a working setup with Rancher managing a kind cluster and a network impairment gateway between cloud and edge networks.

Now, you have a working setup with Rancher managing a kind cluster and a network impairment gateway between cloud and edge networks.