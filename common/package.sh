#!/bin/bash
set -e

source common/ui.sh

ROOTFS="/var/lib/lxc/${CONTAINER}/rootfs"
WORKING_DIR="/tmp/${CONTAINER}"

debug "Creating ${WORKING_DIR}"
mkdir -p ${WORKING_DIR}
mkdir -p $(dirname ${PACKAGE})

# TODO: Create file with build date / time on container

info "Packaging '${CONTAINER}' to '${PACKAGE}'..."

debug 'Stopping container'
lxc-stop -n ${CONTAINER} &>/dev/null || true

if [ -f ${WORKING_DIR}/rootfs.tar.gz ]; then
  log "Removing previous rootfs tarball"
  rm -f ${WORKING_DIR}/rootfs.tar.gz
fi

log "Compressing container's rootfs"
pushd  $(dirname ${ROOTFS})
  tar --numeric-owner --anchored --exclude=./rootfs/dev/log -czf \
      ${WORKING_DIR}/rootfs.tar.gz ./rootfs/*
popd

# Prepare package contents
log 'Preparing box package contents'
if [ -d "distros/${DISTRIBUTION}/conf" ]; then
  if [ -f "distros/${DISTRIBUTION}/conf/${RELEASE}" ]; then
    cp "distros/${DISTRIBUTION}/conf/${RELEASE}" "${WORKING_DIR}/lxc-config"
  elif [ -f "distros/${DISTRIBUTION}/conf/default" ]; then
    cp "distros/${DISTRIBUTION}/conf/default" "${WORKING_DIR}/lxc-config"
  fi
fi

# Prepare package metadata
log 'Preparing box package metadata'
if [ -f "distros/${DISTRIBUTION}/metadata.json" ]; then
  cp "distros/${DISTRIBUTION}/metadata.json" "${WORKING_DIR}"
  sed -i "s/<TODAY>/${NOW}/" "${WORKING_DIR}/metadata.json"
fi

# Vagrant box!
log 'Packaging box'
TARBALL=$(readlink -f ${PACKAGE})
(cd ${WORKING_DIR} && tar -czf $TARBALL ./*)

chmod +rw ${PACKAGE}
chown ${USER}: ${PACKAGE}
