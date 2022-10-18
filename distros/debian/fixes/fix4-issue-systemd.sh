#!/bin/bash
set -e
#=================================================================================================#
#fix4-issue-systemd.sh
#----------
#(2022_10_22)
#
# Resolves issues associated with systemd
# See https://wiki.debian.org/LXC#Incompatibility_with_systemd for more info
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  utils.lxc.start
  
  # Reconfigure the LXC
  utils.lxc.attach /bin/cp /lib/systemd/system/getty@.service /etc/systemd/system/getty@.service

  # Comment out ConditionPathExists
  sed -i -e 's/\(ConditionPathExists=\)/# \n# \1/' "${ROOTFS}/etc/systemd/system/getty@.service"

  # Mask udev.service and systemd-udevd.service:
  utils.lxc.attach /bin/systemctl mask udev.service systemd-udevd.service
  
  utils.lxc.stop

}

#The main function that executes our program
main(){

  local prereq_distro='debian'
  local prereq_releases=(jessie stretch)
  
  if [ "${DISTRIBUTION}" = "$prereq_distro" ] && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
    info "This patch is applicable to [${DISTRIBUTION} - ${RELEASE}]. Applying patch."
    commit_patch $@
  
  else
  
    info "This patch is not for [${DISTRIBUTION} - ${RELEASE}]. Skipping patch."
  
  fi

}

main $@
