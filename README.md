# boot-pxe-lab

This is a pxe image builder for ubuntu 18.04 with vagrant and debootstrap

## Prerequisite

On your host, you need:

* Virtualbox
* Vagrant

On OSX, execute this command with [brew](https://brew.sh/index_fr.html) to install this prerequisites:

```
$ brew cask install vagrant virtualbox
```

## Usage

How to build `pxe-image`:

```
$ make build
```
