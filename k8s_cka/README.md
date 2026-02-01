# K8s Setup With kubeadm

After running `vagrant up` we need to run following command

## Following are for master / control-pane

### Initialize control-pane

```bash
CIDR=10.110.0.0/16
sudo kubeadm config images pull
sudo kubeadm init --pod-network-cidr=$CIDR --apiserver-advertise-address=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1}) \   --node-name $HOSTNAME
```

### In case of mistake  

```bash
sudo kubeadm reset`
```

### Prepare `kubeconfig`

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Install `calico`

```bash
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
# Edit the yaml file set $CIDR value
kubectl apply -f custom-resources.yaml
```


### Intialize worker node

```bash
sudo kubeadm join 172.31.71.210:6443 --token xxxxx --discovery-token-ca-cert-hash sha256:xxx
```

## If forgot to copy token

```bash
kubeadm token create --print-join-command
```

