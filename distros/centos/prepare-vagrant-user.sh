#!/bin/bash
set -e
#=================================================================================================#
#prepare-vagrant-user.sh
#----------
#(2022_12_23)
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
    chroot ${ROOTFS} useradd --create-home -s /bin/bash -u 1000 vagrant
    echo -n 'vagrant:vagrant' | chroot ${ROOTFS} chpasswd
    sed -i 's/^Defaults\s\+requiretty/# Defaults requiretty/' $ROOTFS/etc/sudoers

    if [ ${RELEASE} -eq 6 ]; then
      info 'Disabling password aging for root...'
      # disable password aging (required on Centos 6)
      # pretend that password was changed today (won't fail during provisioning)
      chroot ${ROOTFS} chage -I -1 -m 0 -M 99999 -E -1 -d `date +%Y-%m-%d` root
    fi

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
