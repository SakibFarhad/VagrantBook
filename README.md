# VagrantBook

This is my VM automation book. I use `vagrant` on `libvirt` with `kvm/qemu` provider

For provisoning I use ansible. It is like a magic. 

currently I have following setup:

1. [ubuntu 22.04](ubuntu/)
2. [debian 11](debian/)
3. [CentOS 6](centos6/)
4. [CentOS 7](centos7/)  
5. [CentOS 8](centos8/)
6. [Rocky Linux 8](rocky-linux-9/)

I just copy paste to create new kind of vms. cheers!!

To run this I use **`arch linux` btw!!**

Follow followling steps:

```bash
# Install packages
sudo pacman -S vagrant libvirt qemu-base base-devel bridge-utils openbsd-netcat ebtables iptables libguestfs

# enable libvirt systemd service
sudo systemctl enable --now libvirtd

# allow user to access libvirt without pass, 
sudo usermod -aG libvirt $USER

# install all the pluings form plugins file
vagrant plugin install <pluin-1> <plugin-2> ...

# cd centos/
vagrant up
```

Here vagrant works as my frontend.  
I use `virt-manager` too to sometimes debug the vms

```bash
sudo pacman -S virt-manager
```

