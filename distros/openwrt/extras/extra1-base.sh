#!/bin/bash
set -e
#=================================================================================================#
#extra1-base.sh
#----------
#(2022_12_24)
#
# Base script for installing extra packages
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
  
  while ([ "$ipv4_addr" = '' ] || [ "$ipv4_addr" = '192.168.1.1' ]) && [ "$ipv6_addr" = '' ] && [ $attempt_current -le $attempt_max ] ; do
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

  #local PACKAGES=(curl wget sudo nano vim ca-certificates bash coreutils openssl-util openssh-server)
  local PACKAGES=(curl wget sudo nano vim ca-certificates bash coreutils openssl-util)
  log "Installing additional packages: ${ADDPACKAGES}"
  local PACKAGES+=" ${ADDPACKAGES}"
  
  utils.lxc.start
  
  wait_for_ip
  
  #Provide DNS
  utils.lxc.attach echo 'nameserver 1.1.1.1' > /etc/resolv.conf
  
  #Base Packages
  utils.lxc.attach opkg update
  utils.lxc.attach opkg install ${PACKAGES[*]}
  
  #Coreutils
  local CORE_PACKAGES="coreutils-b2sum coreutils-base32 coreutils-base64 coreutils-basename coreutils-basenc coreutils-cat"
  local CORE_PACKAGES+=" coreutils-chcon coreutils-chgrp coreutils-chmod coreutils-chown coreutils-chroot coreutils-cksum"
  local CORE_PACKAGES+=" coreutils-comm coreutils-cp coreutils-csplit coreutils-cut coreutils-date coreutils-dd coreutils-df"
  local CORE_PACKAGES+=" coreutils-dir coreutils-dircolors coreutils-dirname coreutils-du coreutils-echo coreutils-env"
  local CORE_PACKAGES+=" coreutils-expand coreutils-expr coreutils-factor coreutils-false coreutils-fmt coreutils-fold"
  local CORE_PACKAGES+=" coreutils-groups coreutils-head coreutils-hostid coreutils-id coreutils-install coreutils-join"
  local CORE_PACKAGES+=" coreutils-kill coreutils-link coreutils-ln coreutils-logname coreutils-ls coreutils-md5sum"
  local CORE_PACKAGES+=" coreutils-mkdir coreutils-mkfifo coreutils-mknod coreutils-mktemp coreutils-mv coreutils-nice"
  local CORE_PACKAGES+=" coreutils-nl coreutils-nohup coreutils-nproc coreutils-numfmt coreutils-od coreutils-paste"
  local CORE_PACKAGES+=" coreutils-pathchk coreutils-pinky coreutils-pr coreutils-printenv coreutils-printf coreutils-ptx"
  local CORE_PACKAGES+=" coreutils-pwd coreutils-readlink coreutils-realpath coreutils-rm coreutils-rmdir coreutils-runcon"
  local CORE_PACKAGES+=" coreutils-seq coreutils-sha1sum coreutils-sha224sum coreutils-sha256sum coreutils-sha384sum"
  local CORE_PACKAGES+=" coreutils-sha512sum coreutils-shred coreutils-shuf coreutils-sleep coreutils-sort coreutils-split"
  local CORE_PACKAGES+=" coreutils-stat coreutils-stdbuf coreutils-stty coreutils-sum coreutils-sync coreutils-tac coreutils-tail"
  local CORE_PACKAGES+=" coreutils-tee coreutils-test coreutils-timeout coreutils-touch coreutils-tr coreutils-true"
  local CORE_PACKAGES+=" coreutils-truncate coreutils-tsort coreutils-tty coreutils-uname coreutils-unexpand coreutils-uniq"
  local CORE_PACKAGES+=" coreutils-unlink coreutils-uptime coreutils-users coreutils-vdir coreutils-wc coreutils-who coreutils-whoami coreutils-yes"
  for core_package in ${CORE_PACKAGES[*]}; do

    utils.lxc.attach opkg install $core_package

  done
  
  #SHADOW - User/Group Packages
  local SHADOW_PACKAGES="shadow-chage shadow-chfn shadow-chgpasswd shadow-chpasswd shadow-chsh shadow-common shadow-expiry"
  local SHADOW_PACKAGES+=" shadow-faillog shadow-gpasswd shadow-groupadd shadow-groupdel shadow-groupmems shadow-groupmod"
  local SHADOW_PACKAGES+=" shadow-groups shadow-grpck shadow-grpconv shadow-grpunconv shadow-lastlog shadow-login"
  local SHADOW_PACKAGES+=" shadow-logoutd shadow-newgidmap shadow-newgrp shadow-newuidmap shadow-newusers shadow-nologin"
  local SHADOW_PACKAGES+=" shadow-passwd shadow-pwck shadow-pwconv shadow-pwunconv shadow-su shadow-useradd shadow-userdel"
  local SHADOW_PACKAGES+=" shadow-usermod shadow-utils shadow-vipw"
  for shadow_package in ${SHADOW_PACKAGES[*]}; do

    utils.lxc.attach opkg install $shadow_package

  done
  
  #OPENSSH
  #utils.lxc.attach /etc/init.d/dropbear disable
  #utils.lxc.attach /etc/init.d/dropbear stop
  #utils.lxc.attach /etc/init.d/sshd enable
  #utils.lxc.attach /etc/init.d/sshd start
  
  utils.lxc.stop

}

#The main function that executes our program
main(){

  local prereq_releases=()
  local excluded_releases=()
  
  if (! [[ ${excluded_releases[*]} =~ ${RELEASE} ]]) && ([ ${#prereq_releases[@]} -eq 0 ] || [[ ${prereq_releases[*]} =~ ${RELEASE} ]]); then
  
    info "This patch is applicable to [${DISTRIBUTION} - ${RELEASE}]. Applying patch."
    commit_patch $@
  
  else
  
    info "This patch is not for [${DISTRIBUTION} - ${RELEASE}]. Skipping patch."
  
  fi

}

main $@
