#!/bin/bash
set -e
#=================================================================================================#
#fix1-lxc-startup-fail.sh
#----------
#(2022_12_19)
#
# Without this, the container would fail to start after a shutdown/power off
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  local ROOTFS="/var/lib/lxc/${CONTAINER}/rootfs"

  utils.lxc.stop

  #Disable Umount - https://serverfault.com/questions/580113/lxc-container-starts-with-readonly-root-filesystem
  #/var/lib/lxc/openwrt-example/rootfs
  chroot ${ROOTFS} /etc/init.d/umount disable

}

#The main function that executes our program
main(){

  local prereq_releases=()
  local excluded_releases=()
  
  if (! [[ ${excluded_releases[*]} =~ ${RELEASE} ]]) && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
    info "This patch is applicable to [${DISTRIBUTION} - ${RELEASE}]. Applying patch."
    commit_patch $@
  
  else
  
    info "This patch is not for [${DISTRIBUTION} - ${RELEASE}]. Skipping patch."
  
  fi

}

main $@
