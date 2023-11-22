# kiosk-sagano-example

Demonstration of using the container workflow to build a bootable container image that includes kiosk and a simple script running firefox.

## Notable issues/ergonomics

- Anaconda sets `multi-user.target` as default and whatever we set in the container build isn't honored (will have to file a bug, see https://github.com/rhinstaller/anaconda/blob/ee0b61fa135ba555f29bc6e3d035fbca8bcc14d5/pyanaconda/modules/services/installation.py#L174-L241)
- `useradd` in the container seems to be a no-no, if there was a way to translate that to something using `sysusers.d` that'd be awesome (something in `ostree container commit` perhaps?)
- there are RPMs that writes to `/var` - that's not ideal, either remove or copy them somewhere to later re-inject them using `tmpfiles.d`
- where do we set credentials? root ssh keys in the container may be ok but crendentials in an image seems wrong (also, we can't get rid of `rootpw --iscrypted locked` in the kickstart file)
- where does day 2 mgmt like `flatpak update` belong? since we have to dance a little bit to get the root's flatpak's dir under `/usr` I expect people to _rebuild_ the image right? meaning, nobody runs `flatpak update` on the system, right?

## Images

If you don't want to build youserlf, the following base image is available to be used directly in kickstart:

- `quay.io/runcom/kiosk-base:latest`

You can then follow what's done in `Containerfile.update` and `Containerfile.flatpak` to get an idea about deriving from the base image from your own needs.
The other images are also available:

- `quay.io/runcom/kiosk-base:update`
- `quay.io/runcom/kiosk-base:flatpak`

## Running

There are various ways to test this example:

- install with Anaconda + kickstart
- rebase an existing ostree system
- use a tool to create a bootable disk image

### changing the root ssh key

The ssh key for the root user lives in the main `Containerfile` - change it there as needed. Another option would be to set it in the kickstart file.

### install with Anaconda + kickstart

This has been tested on Fedora 39 and should work simply by following these instructions. Notice we have to disable secure boot since we're using CentOS stream.

```sh
# optional
$ sudo podman build -t quay.io/runcom/kiosk-base:latest .
$ sudo podman push quay.io/runcom/kiosk-base:latest
$ ...
$ sudo cp /usr/share/edk2/ovmf/OVMF_VARS.fd /var/lib/libvirt/qemu/nvram/sagano-demo_VARS.fd
$ curl -O https://dl.fedoraproject.org/pub/fedora/linux/releases/38/Everything/x86_64/os/images/boot.iso
$ virt-install --connect qemu:///system --name sagano-demo --memory 2048 --vcpus 4 --disk size=40 \
          --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader.readonly=yes,loader.secure='no',loader.type=pflash,nvram=/var/lib/libvirt/qemu/nvram/sagano-demo_VARS.fd --network=network=default,model=virtio \
          --os-variant rhel9.0 --location boot.iso \
          --noautoconsole --initrd-inject $(pwd)/example.ks --extra-args="inst.ks=file:/example.ks console=tty0 console=ttyS0,115200 inst.profile=rhel"

```

### rebase an existing ostree system

```sh
$ sudo rpm-ostree rebase ostree-unverified-registry:quay.io/runcom/kiosk-base:latest
$ sudo systemctl reboot
```

### osbuild-deploy-container

If you hack a bit with osbuild, you could also just produce a bootable disk image. See also https://github.com/osbuild/osbuild-deploy-container/ - should be far easier I think. Notice there's a selinux issue and it requires you to disable it until it's fixed https://github.com/osbuild/osbuild-deploy-container/issues/6.

## Updating

You can build and get the update with the following:

```sh
# optional
$ sudo podman build -f Containerfile.update -t quay.io/runcom/kiosk-base:update .
$ sudo podman push quay.io/runcom/kiosk-base:update
$ ...
# in the running vm
$ sudo rpm-ostree rebase ostree-unverified-registry:quay.io/runcom/kiosk-base:update
$ sudo systemctl reboot
```

With the above flow you could also create and rebase to an image that has flatpak and runs GIMP as a kiosk app, see `Containerfile.flatpak`.