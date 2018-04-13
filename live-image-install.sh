#!/bin/bash

echo 'pxe-live' > /etc/hostname

export LANGUAGE=C.UTF-8
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

apt update && apt upgrade -y && apt install -y --no-install-recommends \
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
    ntfs-config \
    ipmitool \
    freeipmi

apt clean

echo bnx2 >> /etc/initramfs-tools/modules
echo ufs >> /etc/initramfs-tools/modules
echo ipmi_devintf >> /etc/initramfs-tools/modules
echo ipmi_si >> /etc/initramfs-tools/modules

echo "root:password" | chpasswd

echo grub-pc grub-pc/install_devices_empty boolean true | debconf-set-selections
echo grub-pc grub2/linux_cmdline string                 | debconf-set-selections
echo grub-pc grub2/linux_cmdline_default string         | debconf-set-selections
