#!/bin/bash
set -e
#=================================================================================================#
#extra2-ansible.sh
#----------
#(2022_10_22)
#
# Script for installing Ansible on container
#=================================================================================================#

source common/ui.sh
source common/utils.sh

#Instead of waiting and praying for X secs, leverage LXC to check if container has an address it understands
#Assume this base container does not have multiples of ipv4 or ipv6
wait_for_ip(){

  local lxc_container_status=$(lxc-ls -f | grep "${CONTAINER}" | sed 's/\ \ */\n/g')
  local ipv4_addr=$(echo -E "$lxc_container_status" | sed -n '5p' | sed -n '/^\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)$/p')
  local ipv6_addr=$(echo -E "$lxc_container_status" | sed -n '6p' | sed -n '/^\([0-9a-fA-F\:]*\)$/p')
  local attempt_current=1
  local attempt_max=60
  
  info "Waiting for container to get address"
  
  while [ "$ipv4_addr" = '' ] && [ "$ipv6_addr" = '' ] && [ $attempt_current -le $attempt_max ] ; do
    sleep 1s
    info ". . . ATTEMPT #$attempt_current"
    lxc_container_status=$(lxc-ls -f | grep "${CONTAINER}" | sed 's/\ \ */\n/g')
    ipv4_addr=$(echo -E "$lxc_container_status" | sed -n '5p' | sed -n '/^\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)$/p')
    ipv6_addr=$(echo -E "$lxc_container_status" | sed -n '6p' | sed -n '/^\([0-9a-fA-F\:]*\)$/p')
    ((attempt_current+=1))
  done
  
  info "Aquired the ip address"
  info ". . . IPv4 = \"$ipv4_addr\""
  info ". . . IPv6 = \"$ipv6_addr\""

}

commit_patch(){

  local ANSIBLE_VERSION=${ANSIBLE_VERSION:-latest}
  local PACKAGES=(build-essential python-setuptools python-jinja2 python-yaml python-paramiko python-httplib2 python-crypto sshpass)
  local download_src="https://releases.ansible.com/ansible/ansible-$ANSIBLE_VERSION.tar.gz"
  local download_dest="/tmp/ansible.tar.gz"

  utils.lxc.start
  
  wait_for_ip
  
  if $(lxc-attach -n ${CONTAINER} -- which ansible &>/dev/null); then
    log "Ansible has been installed on container, skipping"
  else
    log "Installing Ansible"
    utils.lxc.attach apt-get install ${PACKAGES[*]} -y --force-yes
    utils.lxc.attach wget $download_src -O $download_dest
    utils.lxc.attach tar -zxvf $download_dest -C /tmp/
    utils.lxc.attach rm -r $download_dest
    utils.lxc.attach make -C /tmp/ansible-*
    utils.lxc.attach make install -C /tmp/ansible-*
  fi
  
  utils.lxc.stop

}

#The main function that executes our program
main(){

  local prereq_distro='debian'
  local prereq_releases=()
  local target_feature=${ANSIBLE:-0}
  
  if [ "${DISTRIBUTION}" = "$prereq_distro" ] && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
    info "This patch is applicable to [${DISTRIBUTION} - ${RELEASE}]."
    if [ $target_feature = 1 ]; then
      info "Feature has been enabled. Applying patch."
      commit_patch $@
    else
      info "Feature has been disabled. Skipping patch."
    fi
  
  else
  
    info "This patch is not for [${DISTRIBUTION} - ${RELEASE}]. Skipping patch."
  
  fi

}

main $@
