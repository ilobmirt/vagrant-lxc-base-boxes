#!/bin/bash
set -e
#=================================================================================================#
#fix5-issue-bindfs.sh
#----------
#(2022_10_22)
#
# Fix to allow bindfs
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  utils.lxc.start
  
  utils.lxc.attach ln -sf /bin/true /sbin/modprobe
  utils.lxc.attach mknod -m 666 /dev/fuse c 10 229
  
  utils.lxc.stop

}

#The main function that executes our program
main(){

  local prereq_distro='ubuntu'
  local prereq_releases=()
  
  if [ "${DISTRIBUTION}" = "$prereq_distro" ] && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
    info "This patch is applicable to [${DISTRIBUTION} - ${RELEASE}]. Applying patch."
    commit_patch $@
  
  else
  
    info "This patch is not for [${DISTRIBUTION} - ${RELEASE}]. Skipping patch."
  
  fi

}

main $@
