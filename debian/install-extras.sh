#!/bin/bash
set -e

source common/ui.sh
source common/utils.sh

info 'Installing extra packages and upgrading'

debug 'Bringing container up'
utils.lxc.start

# Sleep for a bit so that the container can get an IP
SECS=15
log "Sleeping for $SECS seconds..."
sleep $SECS

PACKAGES=(vim curl wget man-db openssh-server bash-completion ca-certificates sudo)

log "Installing additional packages: ${ADDPACKAGES}"
PACKAGES+=" ${ADDPACKAGES}"

if [ $DISTRIBUTION = 'ubuntu' ]; then
  PACKAGES+=' software-properties-common'
fi
if [ $RELEASE != 'raring' ] && [ $RELEASE != 'saucy' ] && [ $RELEASE != 'trusty' ] && [ $RELEASE != 'wily' ] ; then
  PACKAGES+=' nfs-common'
fi
if [ $RELEASE != 'stretch' ] && [ $RELEASE != 'bullseye' ] ; then
  PACKAGES+=' python-software-properties'
fi
utils.lxc.attach apt-get update
utils.lxc.attach apt-get install ${PACKAGES[*]} -y --force-yes
utils.lxc.attach apt-get upgrade -y --force-yes

ANSIBLE=${ANSIBLE:-0}
CHEF=${CHEF:-0}
PUPPET=${PUPPET:-0}
SALT=${SALT:-0}
BABUSHKA=${BABUSHKA:-0}

if [ $DISTRIBUTION = 'debian' ]; then
  # Enable bash-completion
  sed -e '/^#if ! shopt -oq posix; then/,/^#fi/ s/^#\(.*\)/\1/g' \
    -i ${ROOTFS}/etc/bash.bashrc
fi

if [ $ANSIBLE = 1 ]; then
  if $(lxc-attach -n ${CONTAINER} -- which ansible &>/dev/null); then
    log "Ansible has been installed on container, skipping"
  else
    info "Installing Ansible"
    cp debian/install-ansible.sh ${ROOTFS}/tmp/ && chmod +x ${ROOTFS}/tmp/install-ansible.sh
    utils.lxc.attach /tmp/install-ansible.sh
  fi
else
  log "Skipping Ansible installation"
fi

if [ $CHEF = 1 ]; then
  if $(lxc-attach -n ${CONTAINER} -- which chef-solo &>/dev/null); then
    log "Chef has been installed on container, skipping"
  else
    log "Installing Chef"
    cat > ${ROOTFS}/tmp/install-chef.sh << EOF
#!/bin/sh
curl -L https://www.opscode.com/chef/install.sh -k | sudo bash
EOF
    chmod +x ${ROOTFS}/tmp/install-chef.sh
    utils.lxc.attach /tmp/install-chef.sh
  fi
else
  log "Skipping Chef installation"
fi

if [ $PUPPET = 1 ]; then
  if $(lxc-attach -n ${CONTAINER} -- which puppet &>/dev/null); then
    log "Puppet has been installed on container, skipping"
  elif [ ${RELEASE} = 'sid' ]; then
    warn "Puppet can't be installed on Debian sid, skipping"
  else
    log "Installing Puppet"
    utils.lxc.attach apt-get update
    utils.lxc.attach apt-get install puppet -y --force-yes
  fi
else
  log "Skipping Puppet installation"
fi

if [ $SALT = 1 ]; then
  if $(lxc-attach -n ${CONTAINER} -- which salt-minion &>/dev/null); then
    log "Salt has been installed on container, skipping"
  else
    utils.lxc.attach apt-get update
    utils.lxc.attach apt-get install salt-minion -y --force-yes
  fi
else
  log "Skipping Salt installation"
fi
