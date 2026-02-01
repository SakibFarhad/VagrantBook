#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication on $HOSTNAME"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Update System
echo "[TASK 2] Install required packages and update the system on $HOSTNAME"
sudo apt update
sudo apt install -y vim tmux jq htop build-essential apt-transport-https ca-certificates gpg \
					curl socat conntrack net-tools dnsutils wget nano-
# sudo apt upgrade -y --autoremove
sudo apt-get clean 

# Turn off Swap
echo "[TASK 3] Turn off swap on $HOSTNAME"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install containerd
echo "[TASK 4] Install containerd on $HOSTNAME"
wget -O containerd-1.7.14-linux-amd64.tar.gz https://github.com/containerd/containerd/releases/download/v1.7.14/containerd-1.7.14-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.14-linux-amd64.tar.gz
wget -O containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable containerd


# Install runc
echo "[TASK 5] Install runc on $HOSTNAME"
wget -O runc.amd64 https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Install CNI plugins
echo "[TASK 6] Install CNI plugins on $HOSTNAME"
wget -O cni-plugins-linux-amd64-v1.5.0.tgz https://github.com/containernetworking/plugins/releases/download/v1.5.0/cni-plugins-linux-amd64-v1.5.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.0.tgz

# Install Kubernetes components (kubeadm, kubelet and kubectl)
echo "[TASK 7] Install Kubernetes components (kubeadm, kubelet and kubectl) on $HOSTNAME"
CNI_PLUGINS_VERSION="v1.3.0"
ARCH="amd64"
DEST="/opt/cni/bin"
sudo mkdir -p "$DEST"
wget -O - "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C "$DEST" -xz
DOWNLOAD_DIR="/usr/local/bin"
sudo mkdir -p "$DOWNLOAD_DIR"
CRICTL_VERSION="v1.31.0"
ARCH="amd64"
wget -O - "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz
RELEASE="$(wget -qO - https://dl.k8s.io/release/stable.txt)"
ARCH="amd64"
cd $DOWNLOAD_DIR && sudo wget https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/kubeadm https://dl.k8s.io/release/${RELEASE}/bin/linux/${ARCH}/kubelet
sudo chmod +x {kubeadm,kubelet}
RELEASE_VERSION="v0.16.2"
wget -qO - "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /usr/lib/systemd/system/kubelet.service
sudo mkdir -p /usr/lib/systemd/system/kubelet.service.d
wget -qO - "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl enable kubelet

# Configure crictl
echo "[TASK 8] Configure crictl to use containerd as the default runtime on $HOSTNAME"
sudo crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock

# Enable and load kernel modules
echo "[TASK 9] Enable and load kernel modules on $HOSTNAME"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Verify that the br_netfilter, overlay modules are loaded by running the following commands:
lsmod | grep br_netfilter
lsmod | grep overlay

# Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
sudo modprobe nf_conntrack
echo nf_conntrack | sudo tee /etc/modules-load.d/nf_conntrack.conf

