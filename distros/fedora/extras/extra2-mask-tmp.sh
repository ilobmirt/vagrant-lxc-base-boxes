#!/bin/bash
set -e
#=================================================================================================#
#extra2-mask-tmp.sh
#----------
#(2022_10_22)
#
# Operator declared MASK_TMP
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
  
  utils.lxc.start
  
  wait_for_ip
  
  # don't overmount /tmp with tmpfs: important for lxc-cachier
  utils.lxc.attach systemctl mask tmp.mount
  
  utils.lxc.stop

}

#The main function that executes our program
main(){

  local target_feature=${MASK_TMP:-0}
  
  local prereq_releases=()
  local excluded_releases=()
  
  if (! [[ ${excluded_releases[*]} =~ ${RELEASE} ]]) && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
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
