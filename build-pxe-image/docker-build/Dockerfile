# Use LTS version
FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qqq update && \
    apt-get -qqq upgrade && \
    apt-get -qqq install \
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

RUN true && \
 test -e /.mkrelease || \
 echo grub-pc grub-pc/install_devices_empty boolean true | debconf-set-selections && \
 echo grub-pc grub2/linux_cmdline string | debconf-set-selections && \
 echo grub-pc grub2/linux_cmdline_default string | debconf-set-selections && \
 ( dpkg -l "linux-image-generic*" >/dev/null 2>&1 || apt-get -o DPkg::NoTriggers=true install -y linux-image-generic ) && \
 apt-get -o DPkg::NoTriggers=true install -y live-boot-initramfs-tools live-boot && \
 echo bnx2 >> /etc/initramfs-tools/modules && \
 rm -f /usr/share/initramfs-tools/scripts/live-bottom/10adduser && \
 apt-get -o DPkg::NoTriggers=true install -y squashfs-tools && \
 rm -f /etc/init/plymouth*.conf && \
 ( if [ -e /sbin/initctl.distrib ]; then dpkg-divert --local --remove /sbin/initctl && mv /sbin/initctl.distrib /sbin/initctl; fi ) && \
 dpkg --triggers-only --pending && dpkg --configure --pending && \
 touch /.mkrelease

# Some utilities are not located at the same place as other distros
RUN ln -s /bin/sed /usr/bin/sed
RUN ln -s /usr/bin/basename /bin/basename
RUN ln -s /bin/rm /usr/bin/rm

# Misc
COPY authorized_keys /root/.ssh/authorized_keys
RUN apt-get install -qqq keyboard-configuration console-setup
COPY keyboard /etc/default/keyboard
RUN echo "tzdata tzdata/Zones/Etc select Europe/Paris" | debconf-set-selections && \
    echo "tzdata tzdata/Areas select Europe" | debconf-set-selections && \
    echo "tzdata tzdata/Zones/Europe select Paris" | debconf-set-selections && \
    apt-get install -qqq tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    apt-get install -qqq locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Update e2fs to lastest version
RUN wget -qO /e2fslibs.deb http://fr.archive.ubuntu.com/ubuntu/pool/main/e/e2fsprogs/e2fslibs_1.43.5-1_amd64.deb && \
    dpkg -i /e2fslibs.deb && \
    rm /e2fslibs.deb

RUN wget -qO /e2fsprogs.deb http://fr.archive.ubuntu.com/ubuntu/pool/main/e/e2fsprogs/e2fsprogs_1.43.5-1_amd64.deb && \
    dpkg -i /e2fsprogs.deb && \
    rm /e2fsprogs.deb


RUN echo root:root | chpasswd
