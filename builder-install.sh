#!/bin/bash

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export VAGRANT_PREFER_SYSTEM_BIN=1

export CHROOT_LIVE_IMAGE_PATH=/live_image/

sudo apt-get update -y
sudo apt-get -y install \
    debootstrap \
    syslinux \
    isolinux \
    squashfs-tools \
    tree

sudo mkdir -p $CHROOT_LIVE_IMAGE_PATH

sudo debootstrap \
    --arch=amd64 \
    --variant=minbase \
    bionic $CHROOT_LIVE_IMAGE_PATH

sudo cp /vagrant/live-image-install.sh $CHROOT_LIVE_IMAGE_PATH/live-image-install.sh
sudo cp /etc/apt/sources.list $CHROOT_LIVE_IMAGE_PATH/etc/apt/sources.list
sudo chroot $CHROOT_LIVE_IMAGE_PATH /live-image-install.sh /usr/bin/env -i HOME=/root /bin/bash
