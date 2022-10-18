#!/bin/bash
set -e
#=================================================================================================#
#install-extras.sh
#----------
#(2022_10_22)
#
# This script applies extra software available to the selected distro
#=================================================================================================#

source common/ui.sh
source common/utils.sh

#The main function that executes our program
main(){

  local target_dir="distros/${DISTRIBUTION}/extras"
  local target_script=""
  local executable_targets=""
  
  if [ -d "$target_dir" ] ; then
        
    info "Vagrant lxc extras folder exists"

    executable_targets=$( ls "$target_dir/" -1 | grep ".sh" )
    for file_index in $executable_targets; do

      target_script="$target_dir/$file_index"
      info "Checking out - $target_script"
      $target_script

    done

  else

    info "Vagrant lxc extras folder does not exist"

  fi

}

main $@
