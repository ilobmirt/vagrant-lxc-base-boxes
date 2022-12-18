#!/bin/bash
set -e
#=================================================================================================#
#prepare-vagrant-user.sh
#----------
#(2022_12_18)
#
# It loads the distro specific method of preparing the vagrant user passing the ssh key to it
#=================================================================================================#

source common/ui.sh

cond_run(){

  local file_target="$1"
  local args_target=${@:2}
  
  debug "\nCOND_RUN:\n\tfile_target = $file_target\n\targs_target = $args_target\n"
  
  if [ -f $file_target ]; then
    debug "Script does exist. Run it"
    printf "\n==========\nRUNNING ... $file_target\n==========\n"
    $file_target ${args_target[@]}
  fi

}

#The main function that executes our program
main(){

  local ROOTFS="/var/lib/lxc/${CONTAINER}/rootfs"
  local VAGRANT_KEY="$(cat common/vagrant.key)"
  
  cond_run "distros/${DISTRIBUTION}/prepare-vagrant-user.sh" "${ROOTFS}" "${VAGRANT_KEY}"

}

main $@
