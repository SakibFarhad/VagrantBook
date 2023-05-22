#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Update System
echo "[TASK 2] Install required packages and update the system"
sudo apt-get update
sudo apt-get purge --autoremove snapd nano -y
sudo apt-get install -y vim tmux jq htop \
	curl socat conntrack net-tools dnsutils
sudo apt-get upgrade -y --autoremove
sudo apt-get clean 

# Turn off Swap
echo "[TASK 3] Turn off swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
