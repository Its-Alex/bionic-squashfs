#!/bin/bash
export CHROOT_DIR="$HOME/live_boot/chroot"
export CHROOT_SCRIPTS="$CHROOT_DIR/scripts"

export SCRIPTS_DIR="/home/vagrant/scripts"

rm -rf $HOME/live_boot
mkdir -p $HOME/live_boot
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bionic \
    $CHROOT_DIR

cp -v /etc/apt/sources.list $CHROOT_DIR/etc/apt/sources.list

# mount /proc, /dev, /sys
sudo mount -t proc  /proc $CHROOT_DIR/proc
sudo mount -t sysfs /sys  $CHROOT_DIR/sys
sudo mount --rbind  /dev  $CHROOT_DIR/dev

# Start pxe-live-image installation
mkdir -p -v $CHROOT_SCRIPTS
cp -v $SCRIPTS_DIR/liveos-install.sh $CHROOT_SCRIPTS/
chmod +x $CHROOT_SCRIPTS/liveos-install.sh
sudo chroot $CHROOT_DIR scripts/liveos-install.sh

mkdir $CHROOT_DIR/root/.ssh

cat << EOF > $CHROOT_DIR/root/.ssh/config
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
EOF

# Clean pxe-live-image
rm -rf $CHROOT_SCRIPTS

# unmount all mounted dir
sudo umount --recursive $CHROOT_DIR/proc
sudo umount --recursive $CHROOT_DIR/dev
sudo umount --recursive $CHROOT_DIR/sys

# Create the filesystem.squashfs
mkdir -p $HOME/live_boot/image/live
(cd $HOME/live_boot && \
    mksquashfs chroot image/live/filesystem.squashfs -e boot
)

cp -v $HOME/live_boot/image/live/filesystem.squashfs $HOME/output/filesystem.squashfs
cp -v $CHROOT_DIR/boot/initrd.img-4.15.0-20-generic $HOME/output/initrd.img
cp -v $CHROOT_DIR/boot/vmlinuz-4.15.0-20-generic $HOME/output/vmlinuz
