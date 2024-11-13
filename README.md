# Cloud Native DDIL Test Environment

This repository provides a suite of test environments to simulate and test Disrupted, Disconnected, Intermittent, and Limited (DDIL) network scenarios. 
It offers Docker-based and Oracle Cloud Infrastructure (OCI)-based environments, leveraging the [network impairment gateway](https://github.com/dewcservices/network-impairment-gateway) 
and its [user interface]( https://github.com/dewcservices/network-impairment-gateway-ui), Rancher, Kubernetes, and iPerf3 traffic generation tools.

## Test Environment configurations

Current two type of environments are supported, docker and oci.

## Docker environments

Docker environments a support to provide a simple way of either creating a DDIL environment to test container workloads on a single machine, or to experiment with the network impairment gateway.

### docker-test-environment

**Location**: ./docker-test-environment

**Description**: A minimal DDIL test environment using Docker which establishes two networks `cloud_network` and `edge_network`, with a busybox container in each network
and a network impairment gateway container private connectivity for the cloud and edge networks.
The busybox containers are deployed to each network for basic network exploration, such as ping tests, under DDIL conditions.


**Location**: ./docker-iperf3-environment

**Description**: Uses Docker Compose to deploy two Docker networks, `cloud` and `edge`. This environment includes:
  - A **network impairment gateway** container, configured to simulate DDIL conditions.
  - A **cloud iPerf3 server** container on the cloud network.
  - An **edge iPerf3 client** container on the edge network.
  
  This environment demonstrates how iPerf3 can generate and inject test traffic between cloud and edge networks, showcasing the network impairment gateway’s support for various bearer and environment profile configurations.

- **./docker-k8s-environment**: Deploys Rancher and Kubernetes (K8s) using KIND on a single machine.
  - A **network impairment gateway** container separates the `cloud` and `edge` networks.
  - Rancher is deployed on the `cloud` network, and K8s on the `edge` network.
  
  This setup provides a basic Rancher test environment, demonstrating remote Kubernetes cluster management under DDIL conditions.


- **./oci-test-environment**: Designed for deployment on Oracle Cloud Infrastructure (OCI) with cloud-init files for configuring Oracle Linux VMs.
  - **Cloud VM**: Runs a single-node Rancher instance and iPerf3 server.
  - **Edge VM**: Configures a KIND-based Kubernetes cluster and iPerf3 client.
  - **Network Impairment Gateway VM**: Deploys the network impairment gateway through Docker and directly installs the backend on the VM.

  This environment has been tested on Oracle OCI using Oracle Linux 8 virtual machines.

> **Note**: For OCI deployments, configuring instances in private subnets accessed via a bastion is strongly recommended, as these are example test environments and should not be exposed to the public internet.

## Prerequisites

Ensure you have the following prerequisites:

- **Docker** and **Docker Compose** installed for all Docker-based environments.
- **Oracle OCI instances** with Oracle Linux 8 for OCI-based environments.

Each Docker example can run on a single machine equipped with Docker and Docker Compose, making it easy to get started with minimal setup.

## iPerf3 Traffic Injection

[iPerf3](https://iperf.fr/) is a network testing tool used for measuring and tuning network bandwidth. In this repository, iPerf3 generates controlled traffic between cloud and edge networks, enabling users to configure different DDIL conditions and observe the effect on data throughput and latency.

## Setup and Usage

1. **Docker iPerf3 Environment**
   - Navigate to `./docker-iperf3-environment`.
   - Start the environment with `docker-compose up`.
   - Use iPerf3 commands to simulate traffic and test network impairments.

2. **Docker Kubernetes Environment**
   - Navigate to `./docker-k8s-environment`.
   - Start the environment with `docker-compose up`.
   - Access Rancher on the cloud network to manage the Kubernetes cluster on the edge network.

3. **Docker Test Environment**
   - Navigate to `./docker-test-environment`.
   - Start the environment with `docker-compose up`.
   - Use the Busybox containers to perform simple network tests, such as ping.

4. **OCI Test Environment**
   - Provision Oracle Linux VMs on OCI using the provided cloud-init configurations in `./oci-test-environment`.
   - Deploy Rancher, Kubernetes, and network impairment gateway as outlined in the configurations.

## Testing and Configuration

This repository has been validated on Oracle OCI with Oracle Linux 8 VMs. It is recommended to place all OCI instances in private subnets, accessible only via a bastion host, as these test environments are for experimental purposes and should not be exposed to public networks.

## Contributing

Please feel free to submit pull requests or issues to improve the functionality of this DDIL cloud-native test environment.

---

Happy testing!