#!/bin/bash

set -ev

export ASSETS_DIR="/home/vagrant/assets/"
export OUTPUT_DIR="/home/vagrant/output"
export SCRIPTS_DIR="/home/vagrant/scripts"
export CHROOT_DIR="$HOME/live_boot/chroot"

export CHROOT_SCRIPTS="$CHROOT_DIR/scripts"

# unmount all mounted dir
sudo umount --recursive "$CHROOT_DIR/proc" || true
sudo umount --recursive "$CHROOT_DIR/dev" || true
sudo umount --recursive "$CHROOT_DIR/sys" || true


rm -rf "$HOME/live_boot"
mkdir -p "$HOME/live_boot"
debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bionic \
    "$CHROOT_DIR" \
    http://bouyguestelecom.ubuntu.lafibre.info/ubuntu/

cp -v "$ASSETS_DIR/sources.list" "$CHROOT_DIR/etc/apt/sources.list"

# mount /proc, /dev, /sys
sudo mount -t proc  /proc "$CHROOT_DIR/proc"
sudo mount -t sysfs /sys  "$CHROOT_DIR/sys"
sudo mount --rbind  /dev  "$CHROOT_DIR/dev"

# Start pxe-live-image installation
mkdir -p -v "$CHROOT_SCRIPTS"
cp -v "$SCRIPTS_DIR/liveos-install.sh" "$CHROOT_SCRIPTS/"
chmod +x "$CHROOT_SCRIPTS/liveos-install.sh"
sudo chroot "$CHROOT_DIR" "scripts/liveos-install.sh"

# Setup ssh
mkdir "$CHROOT_DIR/root/.ssh"
cp -v "$ASSETS_DIR/authorized_keys" "$CHROOT_DIR/root/.ssh/"

cat << EOF > "$CHROOT_DIR/root/.ssh/config"
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
EOF

# unmount all mounted dir
sudo umount --recursive "$CHROOT_DIR/proc" || true
sudo umount --recursive "$CHROOT_DIR/dev" || true
sudo umount --recursive "$CHROOT_DIR/sys" || true

# Create the filesystem.squashfs
mkdir -p "$HOME/live_boot/image/live"
(cd "$HOME/live_boot" && \
    mksquashfs chroot image/live/filesystem.squashfs -e boot
)

cp -v "$HOME/live_boot/image/live/filesystem.squashfs" $OUTPUT_DIR/filesystem.squashfs
cp -v "$(echo "$CHROOT_DIR"/boot/initrd.img* | cut -d' ' -f1)" $OUTPUT_DIR/initrd.img
cp -v "$(echo "$CHROOT_DIR"/boot/vmlinuz-* | cut -d' ' -f1)" $OUTPUT_DIR/vmlinuz