# kiosk-sagano-example

Demonstration of using the container workflow to build a bootable container image that include kiosk and a simple script running firefox.

## notable issues

- Anaconda sets multi-user.target as default and whatever we set in the container build isn't honored (will have to file a bug, see https://github.com/rhinstaller/anaconda/blob/ee0b61fa135ba555f29bc6e3d035fbca8bcc14d5/pyanaconda/modules/services/installation.py#L174-L241)

## running

This has been tested on Fedora 39 and should work simply by following these instructions. Notice we have to disable secure boot since we're using CentOS stream.

```sh
$ sudo cp /usr/share/edk2/ovmf/OVMF_VARS.fd /var/lib/libvirt/qemu/nvram/sagano-demo_VARS.fd
$ curl -O https://dl.fedoraproject.org/pub/fedora/linux/releases/38/Everything/x86_64/os/images/boot.iso
$ virt-install --connect qemu:///system --name sagano-demo --memory 2048 --vcpus 4 --disk size=40 \
          --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader.readonly=yes,loader.secure='no',loader.type=pflash,nvram=/var/lib/libvirt/qemu/nvram/sagano-demo_VARS.fd --network=network=default,model=virtio \
          --os-variant rhel9.0 --location boot.iso \
          --noautoconsole --initrd-inject $(pwd)/example.ks --extra-args="inst.ks=file:/example.ks console=tty0 console=ttyS0,115200 inst.profile=rhel"

```

If you hack a bit with osbuild, you could also just produce a bootable disk image. See also https://github.com/osbuild/osbuild-deploy-container/ - should be far easier I think.