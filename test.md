docker run -d --privileged --cpus="1.5" --memory="4g" -p 8080:80 -p 8443:443 -v /home/boswellt/git/cloud-native-edge-ddil-environment/rancher_data:/var/lib/rancher --restart=always rancher/rancher:latest --no-cacert