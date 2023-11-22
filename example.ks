text

# Basic partitioning
clearpart --all --initlabel --disklabel=gpt
part prepboot  --size=4    --fstype=prepboot
part biosboot  --size=1    --fstype=biosboot
part /boot/efi --size=100  --fstype=efi
part /boot     --size=1000  --fstype=ext4 --label=boot
part / --grow --fstype xfs

ostreecontainer --url quay.io/runcom/kiosk-base:latest	--no-signature-verification

# we can inject the ssh key for the root account in the container but we can't
# get rid of this line unfortunately
rootpw --iscrypted locked
reboot

# Workarounds until https://github.com/rhinstaller/anaconda/pull/5298/ lands
bootloader --location=none --disabled
%post --erroronfail
set -euo pipefail
# Work around anaconda wanting a root password
passwd -l root
rootdevice=$(findmnt -nv -o SOURCE /)
device=$(lsblk -n -o PKNAME ${rootdevice})
/usr/bin/bootupctl backend install --auto --with-static-configs --device /dev/${device} /

# anaconda will set multi-user.target by default and won't honor what we've set in the Container
# https://github.com/rhinstaller/anaconda/blob/ee0b61fa135ba555f29bc6e3d035fbca8bcc14d5/pyanaconda/modules/services/installation.py#L174-L241
systemctl set-default graphical.target

%end
