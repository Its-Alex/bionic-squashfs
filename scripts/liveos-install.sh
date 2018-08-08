#!/bin/bash

set -ev

echo "itsalex-live" > /etc/hostname

# Update distrib with locales
apt-get update -y
apt-get install -y locales

locale-gen en_US.UTF-8

echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

# Create user _apt needed by apt-get
adduser --force-badname --system --home /nonexistent --no-create-home --quiet _apt || true

# Install base package
apt-get install -y --no-install-recommends \
    linux-headers-4.15.0-20-generic \
    linux-image-4.15.0-20-generic \
    live-boot \
    live-boot-initramfs-tools \
    squashfs-tools \
    systemd-sysv

# Change root password
echo "root:root" | chpasswd

# Install some packages in pxe-live-image OS
apt-get install -y --no-install-recommends \
    wget \
    curl \
    apt-utils \
    apt-transport-https \
    curl \
    jq \
    vim \
    xz-utils \
    ssh \
    openssh-server \
    gnupg-agent \
    dbus \
    software-properties-common \
    parted \
    hdparm \
    lvm2 \
    qemu-utils \
    smartmontools \
    lshw \
    net-tools \
    iputils-ping \
    ntfs-config \
    smartmontools \
    iproute2 \
    mdadm \
    sshfs \
    ipmitool \
    freeipmi \
    freeipmi-tools \
    e2fsprogs \
    pciutils \
    initramfs-tools \
    xfsprogs

# Enable root ssh login
sed -i "s/^PermitRootLogin .*$//g" /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Clean pxe-live-image OS
apt-get -y clean
apt-get -y autoremove

# Enable module at startup
{
    echo ipmi_si
    echo ipmi_devintf
    echo md
 } >> /etc/modprobe

exit