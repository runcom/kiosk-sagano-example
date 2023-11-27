#!/bin/bash

curl -O https://dl.fedoraproject.org/pub/fedora/linux/releases/38/Everything/x86_64/os/images/boot.iso
virt-install --connect qemu:///system --name sagano-demo --memory 2048 --vcpus 4 --disk size=40 \
          --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader.readonly=yes,loader.secure='no',loader.type=pflash,nvram=/var/lib/libvirt/qemu/nvram/sagano-demo_VARS.fd --network=network=default,model=virtio \
          --os-variant rhel9.0 --location boot.iso \
          --noautoconsole --initrd-inject $(pwd)/example.ks --extra-args="inst.ks=file:/example.ks console=tty0 console=ttyS0,115200 inst.profile=rhel"