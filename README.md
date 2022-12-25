# vagrant-lxc base boxes

This repository contains a set of scripts for creating base boxes for usage with
[vagrant-lxc](https://github.com/fgrehm/vagrant-lxc) 1.4+.

## What distros / versions can I build with this?

* Ubuntu
  - bionic
  - focal
  - jammy
  - kinetic
  - xenial
* Debian
  - buster
  - bullseye
  - bookworm
  - sid
* Fedora
  - 35
  - 36
* CentOS
  - 7
  - 8-Stream
  - 9-Stream
* Alpine
  - 3.13
  - 3.14
  - 3.15
  - 3.16
  - edge
* OpenWRT
  - 21.02
  - 22.03
  - snapshot

## Container Hosts testing this fork

**ARM64**
> OS: Debian GNU/Linux 11 (bullseye) aarch64
> 
> Host: Radxa ROCK Pi 4B

## Status

This is a fork of `hsoft/vagrant-lxc-base-boxes` which itself was a fork for
`fgrehm/vagrant-lxc-base-boxes`. The goal is to make LXC box generation work for LXC 3.0+. The
repo is not in top shape, but it works `make bullseye` (which is what I use myself).

It should be easy enough for you to add support for distros you use (PR welcome).

## Building the boxes

_In order to build the boxes you need to have the `lxc-download`
template available on your machine. If you don't have one around please
create one based on [this](https://github.com/lxc/lxc/blob/master/templates/lxc-download.in)
and drop it on your lxc templates path (usually `/usr/share/lxc/templates`)._

```sh
user@host$ git clone https://github.com/ilobmirt/vagrant-lxc-base-boxes.git
user@host$ cd vagrant-lxc-base-boxes
user@host$ make debian sid
```

By default no provisioning tools will be included but you can pick the ones
you want by providing some environmental variables. For example:

```sh
user@host$ ANSIBLE=1 PUPPET=1 CHEF=1 \
make debian sid
```

Will build a Debian Sid LXC box with latest Ansible, Puppet and Chef pre-installed.

When using ANSIBLE=1, an optional ANSIBLE_VERSION parameter may be passed that
will specify which version of ansible to install. By default it will install
the latest Ansible.

Additional packages to be installed can be specified with the ADDPACKAGES variable:

```sh
user@host$ ADDPACKAGES="aptitude htop" \
make ubuntu xenial
```

Will build a Ubuntu Xenial lxc box with aptitude and htop as additional
packages pre-installed. You can also specify the packages in a file
xenial_packages.

Note: ADDPACKAGES is currently only implemented for flavors of debian.

```sh
user@host$ make debian
Please select a version for debian
Valid versions for debian are the following:
[ buster bullseye bookworm sid]
```
Omitting the version will list available versions for the chosen distro

```sh
user@host$ make clean
cleaning up all projects
    [-] TARGET 'vagrant-base-alpine-edge-arm64' -
    [-] . . . DESTROYING
    [-] TARGET 'vagrant-base-centos-9-Stream-arm64' -
    [-] . . . DESTROYING
    [-] TARGET 'vagrant-base-openwrt-22.03-arm64' -
    [-] . . . STOPPING
    [-] . . . DESTROYING
    [-] Removing 'output/2022-12-25/'
```
When done, user can easily clean up output folder and any/all lxc containers associated with the project

## Pre built base boxes

There are some premade boxes that I have made myself:

* Debian
  - bullseye > "ilobmirt/debian-bullseye-arm64-lxc"
* Alpine
  - 3.16 > "ilobmirt/alpine-3.16-arm64-lxc"

These boxes have been first built by this script before being run locally. Provided they worked for me, will then be pushed to Vagrant. There may be no guarantee that these boxes work for you, even with matching host environment. These premade boxes will have a date based version system of the format 'YY.MMDD'. A box with version '22.1223' would be a premade box released 2022 DEC 23.

## What makes up for a vagrant-lxc base box?

See [vagrant-lxc/BOXES.md](https://github.com/fgrehm/vagrant-lxc/blob/master/BOXES.md)
