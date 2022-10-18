#!/bin/bash
set -e
#=================================================================================================#
#fix1-issue-91.sh
#----------
#(2022_10_21)
#
# Fixes Networking issues in debian
# See https://github.com/fgrehm/vagrant-lxc/issues/91 for more info
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  if ! $(grep -q 'ip6-allhosts' ${ROOTFS}/etc/hosts); then
    log "Adding ipv6 allhosts entry to container's /etc/hosts"
    echo 'ff02::3 ip6-allhosts' >> ${ROOTFS}/etc/hosts
  fi
  
  sed -i -e "s/\(127.0.0.1\s\+localhost\)/\1\n127.0.1.1\t${CONTAINER}\n/g" ${ROOTFS}/etc/hosts

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
