#!/bin/bash

#=================================================================================================#
#mk-box.sh
#----------
#
# Generic script to create a vagrant box
#=================================================================================================#

source common/ui.sh

require_root(){

  printf "\n==========\nrequire_root()\n==========\n"

  if [ "$(id -u)" != "0" ]; then
    echo "You should run this script as root (sudo)."
    exit 1
  fi

}

cond_run(){

  local file_target="$1"
  local args_target=${@:2}
  
  debug "\nCOND_RUN:\n\tfile_target = $file_target\n\targs_target = $args_target\n"
  
  if [ -f $file_target ]; then
    debug "Script does exist. Run it"
    printf "\n==========\nRUNNING ... $file_target ${args_target[@]}\n==========\n"
    $file_target ${args_target[@]}
  fi

}

start_log(){

  printf "\n==========\nstart_log()\n==========\n"

#  local CONTAINER=$1
  local NOW=$(date -u)
  local LOG=$(readlink -f .)/log/${CONTAINER}.log
  
  mkdir -p $(dirname $LOG)
  echo '############################################' > ${LOG}
  echo "# Beginning build at $(date)" >> ${LOG}
  touch ${LOG}
  chmod +rw ${LOG}

}

require_unique_package(){

  printf "\n==========\nrequire_unique_log()\n==========\n"

#  local PACKAGE=$1
  
  if [ -f ${PACKAGE} ]; then
    warn "The box '${PACKAGE}' already exists, skipping..."
    echo
    exit
  fi

}

#The main function that executes our program
main(){

  echo "Generic box script called with params = [$@]"
  
  export DISTRIBUTION=$1
  export RELEASE=$2
  export ARCH=$3
  export CONTAINER=$4
  export PACKAGE=$5
  export ADDPACKAGES=${ADDPACKAGES-$(cat ${RELEASE}_packages | tr "\n" " ")}
  export ROOTFS="/var/lib/lxc/${CONTAINER}/rootfs"
  export WORKING_DIR="/tmp/${CONTAINER}"
    
  require_root
  
  start_log #$CONTAINER
  
  require_unique_package #$PACKAGE
  
  debug "Creating ${WORKING_DIR}"
  mkdir -p ${WORKING_DIR}

  info "Building box to '${PACKAGE}'..."
  
  cond_run ./common/download.sh ${DISTRIBUTION} ${RELEASE} ${ARCH} ${CONTAINER}
  cond_run ./common/vagrant-lxc-fixes.sh ${DISTRIBUTION} ${RELEASE} ${ARCH} ${CONTAINER}
  cond_run ./common/install-extras.sh ${CONTAINER}
  cond_run ./common/prepare-vagrant-user.sh ${DISTRIBUTION} ${CONTAINER}
  cond_run ./distros/${DISTRIBUTION}/clean.sh ${CONTAINER}
  cond_run ./common/package.sh ${CONTAINER} ${PACKAGE}

  info "Finished building '${PACKAGE}'!"
  log "Run \`sudo lxc-destroy -n ${CONTAINER}\` or \`make clean\` to remove the container that was created along the way"
  echo

}

main $@
