#!/bin/bash

export LANGUAGE=C.UTF-8
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

export VAGRANT_PREFER_SYSTEM_BIN=1

export CHROOT_LIVE_IMAGE_PATH=/live_image
export SHARED_FOLDER=/vagrant

cd $SHARED_FOLDER

sudo apt update -y
sudo apt upgrade -y
sudo apt -y install \
    debootstrap \
    syslinux \
    isolinux \
    squashfs-tools \
    tree

sudo mkdir -p $CHROOT_LIVE_IMAGE_PATH

sudo debootstrap \
    --arch=amd64 \
    bionic $CHROOT_LIVE_IMAGE_PATH
    # --variant=minbase \

# mount --bind /dev $CHROOT_LIVE_IMAGE_PATH/dev
# mount --bind /proc $CHROOT_LIVE_IMAGE_PATH/proc

sudo cp $SHARED_FOLDER/live-image-install.sh $CHROOT_LIVE_IMAGE_PATH/live-image-install.sh
sudo cp /etc/apt/sources.list $CHROOT_LIVE_IMAGE_PATH/etc/apt/sources.list
sudo cp /proc/cpuinfo $CHROOT_LIVE_IMAGE_PATH/proc/cpuinfo
sudo chroot $CHROOT_LIVE_IMAGE_PATH /live-image-install.sh /usr/bin/env -i HOME=/root /bin/bash

# umount $CHROOT_LIVE_IMAGE_PATH/dev
# umount $CHROOT_LIVE_IMAGE_PATH/proc

mkdir -p $SHARED_FOLDER/release

mksquashfs $CHROOT_LIVE_IMAGE_PATH/ $SHARED_FOLDER/release/filesystem.squashfs -e boot
cp -v $CHROOT_LIVE_IMAGE_PATH/boot/initrd.img-$(uname -r) $SHARED_FOLDER/release/initrd.img
cp -v $CHROOT_LIVE_IMAGE_PATH/boot/vmlinuz-$(uname -r) $SHARED_FOLDER/release/vmlinuz

