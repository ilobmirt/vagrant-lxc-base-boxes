#!/bin/bash
set -e
#=================================================================================================#
#clean.sh
#----------
#(2022_10_23)
#
# This script removes all the LXC containers we've built.
# Afterwards, it should remove the files that we've created in the target directory
#=================================================================================================#
source common/ui.sh

main(){

  local CONTAINER_REGEX=$1
  local DIR_TARGET=$2
  local LOG=""
  
  local container_status=$(lxc-ls -f | grep -e $CONTAINER_REGEX)
  local target_containers=$(echo -E "$container_status" | sed 's/\ \ */\ /g; s/\([^\ ]*\)/>>>\1<<</1;s/.*>>>//;s/<<<.*//')
  local shutdown_containers=$(echo -E "$container_status" | grep RUNNING | sed 's/\ \ */\ /g; s/\([^\ ]*\)/>>>\1<<</1;s/.*>>>//;s/<<<.*//')
  
  #First, clean up all of our LXC containers matching given regex
  for current_container in $target_containers; do
  
    LOG=$(readlink -f .)/log/${current_container}.log
  
    log "TARGET '${current_container}' -"
  
    #stop container first if it was running
    if [[ ${shutdown_containers[*]} =~ ${current_container} ]]; then
      log ". . . STOPPING"
      lxc-stop -n ${current_container} &>/dev/null || true
    fi

    log ". . . DESTROYING"
    lxc-destroy -n ${current_container}
  
  done
  
  #Then, we clean up our output directory
  if [ -d "$DIR_TARGET" ]; then
    log "Removing '${DIR_TARGET}'"
    rm -rf "$DIR_TARGET"
  fi
  
}

main $@

