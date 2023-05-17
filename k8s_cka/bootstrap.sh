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
sudo apt install -y vim tmux jq htop curl socat conntrack
sudo apt upgrade -y --autoremove