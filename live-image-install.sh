#!/bin/bash

echo 'pxe-live-image' > /etc/hostname

export LANGUAGE=C.UTF-8
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

apt-get update && apt-get install -y --no-install-recommends \
    linux-image-generic \
    live-boot \
    systemd-sysv \
    openssh-server \
    curl \
    apt-utils \
    software-properties-common \
    smartmontools \
    ssh \
    lshw \
    curl \
    iproute2 \
    net-tools \
    vim \
    mc \
    iputils-ping \
    qemu-utils \
    pv \
    lvm2 \
    parted \
    hdparm \
    jq \
    ntfs-config

apt-get clean

echo "password\npassword\n" | passwd root

echo grub-pc grub-pc/install_devices_empty boolean true | debconf-set-selections
echo grub-pc grub2/linux_cmdline string                 | debconf-set-selections
echo grub-pc grub2/linux_cmdline_default string         | debconf-set-selections
