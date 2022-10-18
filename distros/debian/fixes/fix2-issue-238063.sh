#!/bin/bash
set -e
#=================================================================================================#
#fix2-issue-238063.sh
#----------
#(2022_10_22)
#
# Ensure that locales are properly set
# See http://askubuntu.com/a/238063 for more info
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  LANG=${LANG:-en_US.UTF-8}
  
  utils.lxc.start
  
  sed -i "s/^# ${LANG}/${LANG}/" ${ROOTFS}/etc/locale.gen
  
  utils.lxc.attach /usr/sbin/locale-gen ${LANG}
  utils.lxc.attach update-locale LANG=${LANG}
  
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
