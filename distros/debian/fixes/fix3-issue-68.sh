#!/bin/bash
set -e
#=================================================================================================#
#fix3-issue-68.sh
#----------
#(2022_10_22)
#
# Ensures that `/tmp` does not get cleared on halt
# See https://github.com/fgrehm/vagrant-lxc/issues/68 for more info
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  utils.lxc.start
  
  utils.lxc.attach /usr/sbin/update-rc.d -f checkroot-bootclean.sh remove
  utils.lxc.attach /usr/sbin/update-rc.d -f mountall-bootclean.sh remove
  utils.lxc.attach /usr/sbin/update-rc.d -f mountnfs-bootclean.sh remove
  
  utils.lxc.stop

}

#The main function that executes our program
main(){

  local prereq_distro='debian'
  local prereq_releases=()
  
  if [ "${DISTRIBUTION}" = "$prereq_distro" ] && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
    info "This patch is applicable to [${DISTRIBUTION} - ${RELEASE}]. Applying patch."
    commit_patch $@
  
  else
  
    info "This patch is not for [${DISTRIBUTION} - ${RELEASE}]. Skipping patch."
  
  fi

}

main $@
