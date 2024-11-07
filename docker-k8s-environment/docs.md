```sh
# install kind


[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
sudo ln -s /usr/local/bin/kind /usr/bin/kind

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo ln -s /usr/local/bin/kubectl /usr/bin/kubectl

sudo su -
# bring up rancher and impairment gateway
docker-compose -f docker-compose.yaml up -d

# bring up kind cluster
kind create cluster --name edge-cluster --config kind-cluster-config.yaml

# connect kind cluster to the edge network and assign an edge network ip address
CONTROL_PLANE_ID=$(docker ps -q -f "name=edge-cluster-control-plane")
docker network disconnect kind $CONTROL_PLANE_ID
docker network connect --ip 172.19.0.2 network_edge $CONTROL_PLANE_ID

# Rancher
## Accessing UI
# ensure port is forward via vscode https://localhost:8443 - trust insecure connection

## Password
docker logs $(docker ps -q -f name=rancher) 2>&1 | grep "Bootstrap Password:"

## add kind k8s to rancher
### in gui
# - Cluster > Import Existing > Generic > Create
# copy and paste the rancher k8s manifests url

### Apply the rancher k8s manifests url to the kind cluster
curl -k https://localhost:8443/v3/import/<some-rancher-id>.yaml
kubectl apply -f rancher.yaml

# or

curl --insecure -sfL https://localhost:8443/v3/import/<some-rancher-id>.yaml | kubectl apply -f -

# ensure the cluster is active

# delete cluster
kind delete cluster --name edge-cluster

```