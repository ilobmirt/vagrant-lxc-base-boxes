## v1.3.0 (OCT 23 2022)

IMPROVEMENTS:

  - Reorganized project structure to make distro support more modular
  - Added support for ARM64 environments

REGRESSIONS:

  - Removed support for other modes in Makefile outside of box creation and cleanup

OTHER NOTES:

  - Removed much of older unsupported distro versions
  - Removed undocumented unsupported distro - Gentoo

## v1.2.0 (Sep 22, 2014)

IMPROVEMENTS:

  - Remove DHCP leases before packaging


## v1.1.0 (May 3, 2014)

BASE BOXES:

  - Switched to [`lxc-download`](https://github.com/lxc/lxc/blob/master/templates/lxc-download.in)
    as the "reference implementation" for the generic `lxc-template` script [[GH-236]]
  - Added support for _appending_ custom boxes configs with the `lxc-config` file,
    allowing usage of host's specific configs from `/etc/lxc/default.conf` [[GH-222]]
  - Include NFS client on Ubuntu and Debian base boxes [[GH-218]]
  - Improved output for building base boxes
  - Improved `vagrant` user `sudo` rights [[GH-231]] [[GH-188]]
  - Locale configuration may follow builder's LANG environment variable [[GH-221]]
  - Enable bash completion for Debian base boxes [[GH-220]]
  - Fix broken locale in Ubuntu boxes [[GH-201]]
  - Install `python-software-properties` by default [[GH-155]]
  - Fix apt-get error when building Ubuntu boxes [[GH-200]]

[GH-236]: https://github.com/fgrehm/vagrant-lxc/issues/236
[GH-222]: https://github.com/fgrehm/vagrant-lxc/issues/222
[GH-218]: https://github.com/fgrehm/vagrant-lxc/issues/218
[GH-231]: https://github.com/fgrehm/vagrant-lxc/issues/231
[GH-221]: https://github.com/fgrehm/vagrant-lxc/issues/221
[GH-220]: https://github.com/fgrehm/vagrant-lxc/issues/220
[GH-201]: https://github.com/fgrehm/vagrant-lxc/issues/201
[GH-188]: https://github.com/fgrehm/vagrant-lxc/issues/188
[GH-155]: https://github.com/fgrehm/vagrant-lxc/issues/155
[GH-200]: https://github.com/fgrehm/vagrant-lxc/issues/200


## Previous

The changelog began with version 1.1.0 and before that the changes
were being tracked from [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc/blob/master/CHANGELOG.md).
