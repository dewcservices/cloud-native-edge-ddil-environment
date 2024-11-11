# Iperf3 Client

```sh
docker exec -it iperf3_edge iperf3 -c <iperf3-server-ip>
```
# Edge K8S Cluster

## Kind

### Configure kind Cluster Configuration File

Create or modify the kind cluster configuration file to specify the external address for the API server to bind to the VM's VNIC.

kind-config.yaml
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "<vm-vnic-ip-address>"
  apiServerPort: 6443
nodes:
  - role: control-plane
```

Replace <vm-vnic-ip-address> with the actual IP address of your VM's VNIC (e.g., 192.168.1.10).

### Create the kind Cluster

Use the kind configuration file to create the cluster:
```sh
kind create cluster --config kind-config.yaml
```

### Verify the API Server's Availability

Check that the API server is listening on the desired IP by running:

```sh
kubectl cluster-info --kubeconfig=<path-to-kubeconfig>
```

You should see that the control plane is accessible at https://<vm-vnic-ip-address>:6443.

### Open Firewall Ports (if needed)

Ensure that the VM's firewall allows traffic to the API server port (6443 by default). Update the firewall rules if necessary to allow inbound traffic on this port.