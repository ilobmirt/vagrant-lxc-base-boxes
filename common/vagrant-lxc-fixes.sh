#!/bin/bash
set -e
#=================================================================================================#
#vagrant-lxc-fixes.sh
#----------
#(2022_10_21)
#
# This script applies a collection of patches for the selected distro
#=================================================================================================#

source common/ui.sh
source common/utils.sh

#The main function that executes our program
main(){

  local target_dir="distros/${DISTRIBUTION}/fixes"
  local target_script=""
  local executable_targets=""
  
  if [ -d "$target_dir" ] ; then
        
    info "Vagrant lxc fixes folder exists"

    executable_targets=$( ls "$target_dir/" -1 | grep ".sh" )
    for file_index in $executable_targets; do

      target_script="$target_dir/$file_index"
      info "Checking out - $target_script"
      $target_script $@

    done

  else

    info "Vagrant lxc fixes folder does not exist"

  fi

}

main $@
