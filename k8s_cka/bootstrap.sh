#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Update System
echo "[TASK 2] Install required packages and update the system"
sudo apt update
sudo apt purge --autoremove snapd nano -y
sudo apt install -y vim tmux jq htop \
	curl socat conntrack net-tools dnsutils wget
# sudo apt upgrade -y --autoremove
# sudo apt-get clean 

# Turn off Swap
echo "[TASK 3] Turn off swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "[TASK 4] Install containerd"
wget -c "https://download.docker.com/linux/debian/dists/bookworm/pool/stable/amd64/containerd.io_2.2.1-1~debian.12~bookworm_amd64.deb" -O containerd.io_2.2.1-1.deb

sudo dpkg -i /tmp/containerd.io_2.2.1-1.deb
sudo apt install -f
sudo systemctl enable --now containerd
