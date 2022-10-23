#!/bin/bash
set -e
#=================================================================================================#
#fix1-download-systemd.sh
#----------
#(2022_10_23)
#
# Moved systemd support patch from common/download.sh
#=================================================================================================#

source common/ui.sh
source common/utils.sh

commit_patch(){

  local patch_contents=$(cat <<EOF

# settings for systemd with PID 1:
lxc.autodev = 1
EOF
)

  utils.lxc.stop

  echo "${patch_contents}" | sudo tee -a /var/lib/lxc/${CONTAINER}/config > /dev/null

  utils.lxc.start
  utils.lxc.attach rm -f /dev/kmsg
  utils.lxc.stop

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
