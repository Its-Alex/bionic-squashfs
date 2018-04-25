#!/bin/bash
echo 'pxe-live-xenial' > /etc/hostname

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Create user _apt needed by apt-get
adduser --force-badname --system --home /nonexistent --no-create-home --quiet _apt || true

apt-get update -y
apt-get install -y --no-install-recommends \
    linux-headers-$(uname -r) \
    linux-image-$(uname -r) \
    live-boot \
    live-boot-initramfs-tools \
    squashfs-tools \
    systemd-sysv \
    locales

locale-gen en_US.UTF-8

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
    pv \
    xz-utils \
    ssh \
    openssh-server \
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
    freeipmi-tools

# Enable root ssh login
sed -i 's/^PermitRootLogin .*$//g' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Clean pxe-live-image OS
apt-get -y clean
apt-get -y autoremove

# Enable module at startup
echo ipmi_si >> /etc/modprobe
echo ipmi_devintf >> /etc/modprobe
echo md >> /etc/modprobe

exit
