#!/usr/bin/env python3

"""
build a pxe image from a Dockerfile
Greatly inspired by: docker_to_pxe.pl


usage: docker_to_pxe.py [-h] [--build] [--generate] [--release RELEASE]
                        [--no-cache] [-t [TAG]] [-f [RELEASE_FOLDER]]
                        [dockerfile]

positional arguments:
  dockerfile            Dockerfile to use

optional arguments:
  -h, --help            show this help message and exit
  --build               Build the docker image
  --generate            Generate the squashfs file
  --release RELEASE     Make release
  --no-cache            Do not use cache when building image
  -t [TAG], --tag [TAG]
                        Docker image tag
  -f [RELEASE_FOLDER], --release-folder [RELEASE_FOLDER]
                        Release folder
"""


###
# Configuration
###

DEFAULT_TAG = "docker-registry.mutu.online.net/c14/dfe"
DEFAULT_RELEASE_DIR = "releases"

###
# End configuration
###

# TODO:
# - move the full configuration to the args
# - link postboot images

import argparse
import ctypes
import re
import sys
import tempfile
from typing.io import TextIO
import os
from subprocess import run, PIPE

# Added in the Dockerfile
MKRELEASE = """
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
#RUN update-initramfs -u
"""

# Script to create a squashfs inside the container
# `{image_id}` must be replaced
GENERATE = """
set -eux
image_id="{image_id}"

cp -p /tmp/.parents /.parents

rm /.mkrelease
mkdir /tmp/mkrelease/

if [ -e /vmlinuz ]; then type=vmlinuz; else type=vmlinux; fi
version="$(readlink -f /${{type}} | cut -d- -f2-)"
cp -p /boot/${{type}}-"$version" /tmp/mkrelease/${{type}}
cp -p /boot/initrd.img-"$version" /tmp/mkrelease/initrd.img
apt-get clean
find /var/lib/apt/lists/ -type f -regextype posix-egrep -regex '.*(_Packages|_Sources|_Release|\.gpg)' -delete
rm -f /var/cache/apt/pkgcache.bin /var/cache/apt/srcpkgcache.bin
find /var/log/ -type f -delete

mksquashfs / /tmp/mkrelease/filesystem.squashfs -wildcards -ef /tmp/excludes.gen
"""

def unshare_mount() -> None:
    """Mount the appropriate folders to fool Docker"""
    libc = ctypes.CDLL(None, use_errno=True)
    pid = os.getpid()

    # unshare(CLONE_NEWNS)
    call = libc.syscall(272, 0x00020000)
    if call < 0:
        print("Could not share mount namespace", file=sys.stderr)
        print(os.strerror(ctypes.get_errno()), file=sys.stderr)
        sys.exit(call)

    run(['/bin/mount',
         '-n',
         '--make-rslave', '/'])
    run(['/bin/mount',
         '-n',
         '--bind', '/proc/%i/mounts' % pid,
         '/etc/mtab'])
    run(['/bin/mount',
         '-t', 'tmpfs',
         '-o', 'size=1m', 'none',
         '/tmp'])

def _create_release_df(input: TextIO, output: TextIO) -> None:
    """Replace MKRELEASE with the appropriate data"""
    found_release = False
    for line in input:
        if re.match(r'^MKRELEASE$', line):
            output.write(MKRELEASE)
            found_release = True
        else:
            output.write(line)
    if not found_release:
        print('warning: MKRELEASE instruction not in Dockerfile')

def _get_image_id(tag: str) -> str:
    """Return the image  `tag` id"""
    proc = run(['docker', 'inspect', '--format={{.Id}}', tag],
               stdout=PIPE)
    id = proc.stdout.decode().strip().split(':')[-1][:12]
    return id


def build(dockerfile_path: str, tag: str, cache: bool=False) -> None:
    """Create a Docker image with the MKRELEASE command"""
    # TODO: tag image with the date
    df_handler, temp_file_name = tempfile.mkstemp(suffix='tmp', dir='/tmp')
    with open(dockerfile_path) as dockerfile, \
         open(temp_file_name, 'w') as df_temp:
        _create_release_df(dockerfile, df_temp)

    run(['/bin/mount',
         '-n',
         '--bind', temp_file_name, dockerfile_path])
    run(['/sbin/modprobe', 'aufs'])

    docker_args = [] if cache else ['--no-cache']
    dockerfile_dir = os.path.dirname(os.path.abspath(dockerfile_path))
    run(['/usr/bin/docker', 'build', *docker_args,
         '-t', tag, '--', dockerfile_dir])

    os.close(df_handler)


def generate(dockerfile_path: str, tag: str, release_folder: str) -> str:
    """
    Generate a squashfs file from the `tag` image and save it under
    `release_folder`
    The `release_folder` will look like the following:
        - `image_id`: folder with the data
          - filesystem-current-generic.squashfs
          - initrd.img-current-generic
          - vmlinuz-current-generic
        - current -> `image_id`: link to the latest build
        - filesystem-current-generic.squashfs -> current/filesystem-current-generic.squashfs
        - initrd.img-current-generic -> current/initrd.img-current-generic
        - vmlinuz-current-generic -> current/vmlinuz-current-generic
    """
    # if the image does not exists
    script_dir = os.path.dirname(__file__)
    df_dir = os.path.dirname(os.path.abspath(dockerfile_path))
    image_id = _get_image_id(tag)
    run(['rm', '-rf',
         os.path.join(df_dir, 'tmp/')])
    run(['mkdir',
         os.path.join(df_dir, 'tmp/')])
    run(['cp', '-p',
         os.path.join(script_dir, 'postboot'),
         os.path.join(df_dir, 'tmp/')])
    run(['cp', '-p',
         os.path.join(script_dir, 'excludes.base'),
         os.path.join(df_dir, 'tmp', 'excludes.gen')])
    run(['touch',
         os.path.join(df_dir, 'tmp', '.parents')])
    generate = GENERATE.format(image_id=image_id)
    run(['/usr/bin/docker',
         'run', '--rm=true',
         '-v',  '%s:/tmp' % os.path.join(df_dir, 'tmp'),
         '--entrypoint=/usr/bin/env',
         '%s:latest' % tag,
         '--', 'sh', '-c', generate])

    run(['mkdir', '-p', release_folder])
    run(['rsync', '-a', '-vv', '-i',
         '--chmod=a-w,a+r',
         os.path.join(df_dir, 'tmp', 'mkrelease', ''),
         os.path.join(release_folder,)])


def link(image):
    """Link the postboot scripts"""
    pass


def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--build',
                        action='store_true', dest='build', default=False,
                        help='Build the docker image')
    parser.add_argument('--generate',
                        action='store_true', dest='generate', default=False,
                        help='Generate the squashfs file')
    parser.add_argument('--release', dest='release', default=False,
                        help='Make release')


    parser.add_argument('--no-cache',
                        action='store_false', dest='cache', default=True,
                        help='Do not use cache when building image')
    parser.add_argument('-t', '--tag', nargs='?', dest='tag',
                        default=DEFAULT_TAG,
                        help='Docker image tag')
    parser.add_argument('-f', '--release-folder', nargs='?', dest='release_folder',
                        default=DEFAULT_RELEASE_DIR,
                        help='Release folder')
    parser.add_argument('dockerfile', nargs='?', default='Dockerfile',
                        help='Dockerfile to use')

    return parser.parse_args()

def main() -> None:
    args = _parse_args()
    unshare_mount()

    if args.build:
        build(args.dockerfile, args.tag, args.cache)
    if args.generate:
        generate(args.dockerfile, args.tag, args.release_folder)
    if args.release:
        raise NotImplementedError('RELEASE not implemented yet')

if __name__ == '__main__':
    main()
