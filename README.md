# vagrant-lxc base boxes

This repository contains a set of scripts for creating base boxes for usage with
[vagrant-lxc](https://github.com/fgrehm/vagrant-lxc) 1.4+.

## What distros / versions can I build with this?

* Ubuntu
  - Trusty (2014.04) (x86_64 + arm64)
  - Xenial (2016.04) (x86_64 + arm64)
* Debian
  - Jessie (2015.04) (x86_64 + arm64)
  - Stretch (2017.06) (x86_64 + arm64)
  - Bullseye (2021.08) (x86_64 + arm64)
  - Sid (x86_64 + arm64)
* Fedora
  - 23 (2015.11) (x86_64 + arm64)
  - rawhide (x86_64 + arm64)
* CentOS
  - 7 (2014.07) (x86_64 + arm64)

## Distros tested from this fork
* Debian
  - Bullseye (2021.08) (arm64)

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
git clone https://github.com/hsoft/vagrant-lxc-base-boxes.git
cd vagrant-lxc-base-boxes
make stretch
```

By default no provisioning tools will be included but you can pick the ones
you want by providing some environmental variables. For example:

```sh
ANSIBLE=1 PUPPET=1 CHEF=1 \
make stretch
```

Will build a Debian Stretch x86_64 box with latest Ansible, Puppet and Chef pre-installed.

When using ANSIBLE=1, an optional ANSIBLE_VERSION parameter may be passed that
will specify which version of ansible to install. By default it will install
the latest Ansible.

Additional packages to be installed can be specified with the ADDPACKAGES variable:

```sh
ADDPACKAGES="aptitude htop" \
make xenial
```

Will build a Ubuntu Xenial x86_64 box with aptitude and htop as additional
packages pre-installed. You can also specify the packages in a file
xenial_packages.

Note: ADDPACKAGES is currently only implemented for flavors of debian.

## Pre built base boxes

There are no pre-built base boxes for this repo. You have to build them yourself.

## What makes up for a vagrant-lxc base box?

See [vagrant-lxc/BOXES.md](https://github.com/fgrehm/vagrant-lxc/blob/master/BOXES.md)

