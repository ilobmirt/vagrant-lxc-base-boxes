#!/bin/bash
set -e
#=================================================================================================#
#prepare-vagrant-user.sh
#----------
#(2022_12_18)
#
# Prepares the operating system for the Vagrant user
#=================================================================================================#
source common/ui.sh

#The main function that executes our program
main(){

  local ROOTFS="$1"
  local VAGRANT_KEY="${@:2}"
  
  # Create vagrant user
  if $(grep -q 'vagrant' ${ROOTFS}/etc/shadow); then
    log 'Skipping vagrant user creation'
  else
    debug 'Creating vagrant user...'
    chroot ${ROOTFS} groupadd -r vagrant
    chroot ${ROOTFS} useradd -r -m --gid=vagrant --shell=/bin/bash vagrant
    echo -n 'vagrant:vagrant' | chroot ${ROOTFS} chpasswd
  fi

  # Configure SSH access
  if [ -d ${ROOTFS}/home/vagrant/.ssh/authorized_keys ]; then
    log 'Skipping vagrant SSH credentials configuration'
  else
    debug 'SSH key has not been set'
    mkdir -p ${ROOTFS}/home/vagrant/.ssh
    echo $VAGRANT_KEY > ${ROOTFS}/home/vagrant/.ssh/authorized_keys
    chroot ${ROOTFS} chown -R vagrant: /home/vagrant/.ssh
    log 'SSH credentials configured for the vagrant user.'
  fi
  
  # Enable passwordless sudo for the vagrant user
  if [ -f ${ROOTFS}/etc/sudoers.d/vagrant ]; then
    log 'Skipping sudoers file creation.'
  else
    debug 'Sudoers file was not found'
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" > ${ROOTFS}/etc/sudoers.d/vagrant
    chmod 0440 ${ROOTFS}/etc/sudoers.d/vagrant
    log 'Sudoers file created.'
  fi

}

main $@
