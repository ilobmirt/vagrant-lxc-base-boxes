#!/bin/bash

#=================================================================================================#
#download.sh
#----------
#
#Common script to download a container from central LXC repository to be used in vagrant
#=================================================================================================#
set -e

source common/ui.sh
source common/utils.sh

unique_container(){
  # If container exists, check if want to continue
  if $(lxc-ls | grep -q ${CONTAINER}); then
    if ! $(confirm "The '${CONTAINER}' container already exists, do you want to continue building the box?" 'y'); then
      log 'Aborting...'
      exit 1
    fi
  fi

  # If container exists and wants to continue building the box
  if $(lxc-ls | grep -q ${CONTAINER}); then
    if $(confirm "Do you want to rebuild the '${CONTAINER}' container?" 'n'); then
      log "Destroying container ${CONTAINER}..."
      utils.lxc.stop
      utils.lxc.destroy
    else
      log "Reusing existing container..."
      exit 0
    fi
  fi
}

make_container(){

  # If we got to this point, we need to create the container
  log "Creating container..."

  utils.lxc.create -t download -- \
                   --dist ${DISTRIBUTION} \
                   --release ${RELEASE} \
                   --arch ${ARCH}

}

main(){

  unique_container

  make_container

  log "Container created!"
  
}
 
 main $@
