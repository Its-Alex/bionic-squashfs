## Prerequisite

On your host, you need:

* Virtualbox
* Vagrant

On OSX, execute this command with [brew](https://brew.sh/index_fr.html) to install this
prerequisite:

```
$ brew cask install vagrant virtualbox
$ vagrant plugin install vagrant-disksize
```

## Quickstart

```
$ vagrant up pxe_server
$ vagrant ssh pxe_server
```

Start `blank_server`:

```
$ vagrant up blank_server_1
```

`pxe-live-image` access: *

* login :`root`
* password: `root`
