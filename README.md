# VagrantBook

This is my VM automation book. I use `vagrant` with `libvirt` or `kvm/qemu` provider

For provisoning I use ansible. It is like a magic. 

currently I have two setup:

1. [centos](centos/)  
1. [ubuntu](ubuntu/)

I just copy paste to create new kind of vms. cheers!!

To run this I use **`arch linux` btw!!**

Follow followling steps:

```bash
# Install packages
sudo pacman -S vagrant libvirt qemu base-devel ansible

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

