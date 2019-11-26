#!/bin/bash
# --------------------------------------------
# Install LXD, create Alpine Linux LXD image
# and container, configure container with
# shared directory and ssh access.
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keegan@kmauthorized.com
# License: keegoid.mit-license.org
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  SETUP PARAMETERS

[ -z "$QC_REPOS" ] && read -rep "Directory to use for repositories: ~/" -i "f-drive/coding/repos" QC_REPOS
QC_SELECTED_CONTAINER

# --------------------------  INSTALL LXD/LXC

# install Juju, ZFS and LXD
qc_install_juju_zfs_lxd() {
  # if lkm_not_installed juju2; then
  #     sudo apt-add-repository -y ppa:juju/devel
  #     sudo apt-get update
  #     lkm_install_apt juju2
#        [ "$QC_IS_SERVER" -eq 0 ] && lkm_install_apt juju || lkm_install_apt juju-local
  # else
  #     notify "Juju2 is already installed"
  # fi
  lkm_install_apt "zfsutils-linux lxd criu"

  RET="$?"
  lkm_debug
}

# --------------------------  INIT JUJU AND LXD WITH ZFS

qc_init_juju_lxd() {
  lkm_notify3 "At this point you could exit this script and set up your ZFS pool manually on some physical hard drives per instructions at:"
  lkm_notify3 "http://goo.gl/z6Xg5Z and https://goo.gl/1e3a5e"
  lkm_confirm "Create a sparse, loopback file for the ZFS pool instead?" true
  # create zfs block
  [ $? -eq 0 ] && sudo lxd init

  # set compression and turn off dedup
  read -rep "Enter the name you used for your zpool: " zpool_name
  sudo zfs set compression=on "$zpool_name"
  sudo zfs set compression=lz4 "$zpool_name"
  sudo zfs set dedup=off "$zpool_name"
  lkm_success "set compression to lz4 and disabled dedup on $zpool_name"

  # add cron job to scrub zpool weekly
  echo -e "#!/bin/sh\n/sbin/zpool scrub $zpool_name" | sudo tee /etc/cron.weekly/zfsscrub
  sudo chmod +x /etc/cron.weekly/zfsscrub

  # limit memory usage by zpool
  echo -e "# Limit arc to 1GB\noptions zfs zfs_arc_max=1073741824" | sudo tee /etc/modprobe.d/zfs.conf

  # verify zfs
  sudo zpool list
  sudo zpool status

  # set Juju to work with LXD
#    lkm_pause "Press [Enter] to init Juju"
#    juju init
#    mv -n ~/.juju/environments.yaml ~/.juju/environments-old.yaml
#    echo -e "default: local\n\nenvironments:\n\n\tlxd:\n\ttype: lxd" | tee ~/.juju/environments.yaml
#    juju init --show
#    juju switch lxd
#    juju bootstrap --upload-tools

  RET="$?"
  lkm_debug
}

# --------------------------  UBUNTU IMAGE

# import base ubuntu image for LXD
qc_import_lxd_image() {
  lkm_not_installed lxd && qc_install_juju_zfs_lxd

  # copy image from remote server to local image store
  # old way
  # lxd-images import ubuntu trusty amd64 --sync --alias ubuntu-trusty
  # new way
  lxc image copy ubuntu:trusty/amd64 local: --alias ubuntu-trusty --auto-update && lkm_success "lkm_successfully imported ubuntu image to lxc image store"

  RET="$?"
  lkm_debug
}

# --------------------------  HOST NAME

# add ip address and host name to /etc/hosts
# $1 -> host name
qc_set_hosts() {
  lxc list
  read -rep "Type an existing container name to use for ${1}: " QC_SELECTED_CONTAINER

  # add container's ip to /etc/hosts
  lkm_pause "Press [Enter] to add $1 to /etc/hosts"
  local ipv4
  ipv4=$(lxc list | grep "$QC_SELECTED_CONTAINER" | cut -d "|" -f 4 | cut -d " " -f 2)

  # remove entry if it already exists
  if grep "$1" /etc/hosts >/dev/null; then
    sudo sed -i.bak "/$1/d" /etc/hosts
  fi

  # wait for ip address to get assigned to container
  while [ -z "$ipv4" ]; do
    lkm_notify3 "The container hasn't been assigned an IP address yet."
    lkm_pause "Press [Enter] to try again" true
    ipv4=$(lxc list | grep "$QC_SELECTED_CONTAINER" | cut -d "|" -f 4 | cut -d " " -f 2)
  done

  # add new hosts entry
  if [ -n "$ipv4" ]; then
    echo -e "${ipv4}\t${1}" | sudo tee --append /etc/hosts
    lkm_success "lkm_successfully added ${ipv4} and ${1} to /etc/hosts"
  else
    lkm_notify2 "Couldn't add ${1} to /etc/hosts, missing IP address on container."
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  SHARED DIRECTORY

# create shared directory to sync files between host and container
# $1 -> host name
qc_set_shared_directory() {
  # set syncing directory paths
  read -rep "Choose a source directory on host to sync: ~/${QC_REPOS}/" -i "${1}/site" relative_source
  read -rep "Choose a target directory in container to sync: /" -i "var/www/${1}/public_html" target_dir
  source_dir="$HOME/${QC_REPOS}/$relative_source"
  target_dir="/${target_dir}"

  lkm_pause "Press [Enter] to configure shared directory between host and container"
  # make source and target directories and configure with proper permissions
  mkdir -p "$source_dir"
  sudo chgrp 165536 "$source_dir"
  sudo chmod g+s "$source_dir"
  #   sudo setfacl -d -m u:lxd:rwx,u:$(whoami):rwx,u:165536:rwx,g:lxd:rwx,g:$(whoami):rwx,g:165536:rwx "$source_dir"
  lxc exec "${QC_SELECTED_CONTAINER}" -- su - root -c "mkdir -p $target_dir"
  # check if device already exists and remove it if it does
  if lxc config device list "${QC_SELECTED_CONTAINER}" >/dev/null | grep "shared-${1}"; then
    lxc config device remove "${QC_SELECTED_CONTAINER}" "shared-${1}"
  fi
  # add new device for shared directory
  lxc config device add "${QC_SELECTED_CONTAINER}" "shared-${1}" disk source="$source_dir" path="$target_dir" && lkm_success "Successfully configured syncing of $source_dir on host with $target_dir in container."

  RET="$?"
  lkm_debug
}

# --------------------------  SSH KEY

# add ssh key to authorized keys in container
qc_set_authorized_key() {
  # if no ssh key, generate one
  [ -f "$HOME/.ssh/id_rsa.pub" ] || lkm_gen_ssh_key "$HOME/.ssh" "$(whoami)"
  lkm_pause "Press [Enter] to copy public your ssh key to \"authorized_keys\" in container"
  # make .ssh directory if it doesn't exist
  lxc exec "${QC_SELECTED_CONTAINER}" -- su - root -c "mkdir -p .ssh"
  # push public ssh key to container
  lxc file push "$HOME/.ssh/id_rsa.pub" "${QC_SELECTED_CONTAINER}/root/.ssh/authorized_keys" && lkm_success "Successfully added ssh key to ${QC_SELECTED_CONTAINER}."

  RET="$?"
  lkm_debug
}

# --------------------------  CREATE CONTAINER

# create new lxd container from latest image
qc_create_lxd_container() {
  local selected_image
  local host_name
  local relative_source
  local target_dir
  local source_dir

  # select an image and choose a container name
  lxc image list
  read -rep "Select an image to use for the new container: " -i 'ubuntu-trusty' selected_image
  read -rep "Enter a host name to use with /etc/hosts: " -i 'wordpress.dev' host_name

  # create and start container
  lxc launch "$selected_image"

  qc_set_hosts "$host_name"

  qc_set_shared_directory "$host_name"

  qc_set_authorized_key

  # install and run easyengine inside ubuntu container
#    lxc exec "${QC_SELECTED_CONTAINER}" -- su - root -c "wget -qO ee rt.cx/ee && sudo bash ee"
#    lxc exec "${QC_SELECTED_CONTAINER}" -- su - root -c "sudo ee site create ${host_name} --wpfc"

  RET="$?"
  lkm_debug
}

# --------------------------  DEPLOY WORDPRESS

# deploy WordPress to container using Juju
qc_deploy_wordpress() {
  local git_repo

  juju deploy mysql
  juju deploy memcached
  juju deploy wordpress
  #    watch juju status
  juju add-relation wordpress mysql
  juju expose wordpress
  juju set wordpress tuning=optimized

  # optionally set wp-content to git repository
  lkm_confirm "Use a git repository for wp-content?" true
  [ $? -eq 0 ] && lkm_notify3 "Format: git@host:path/repo.git or http://host/path/repo.git" && read -rep "Enter a git repository: " git_repo && juju set wordpress wp-content="$git_repo"

  RET="$?"
  lkm_debug
}

# add memcached relation
qc_add_memcached() {
  # configure WordPress and add first user, then we can add memcached relation
  juju add-relation memcached wordpress

  # shellcheck disable=SC2034
  RET="$?"
  lkm_debug
}

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the script
qc_reset() {
  unset -f qc_reset qc_install_juju_zfs_lxd qc_init_juju_lxd qc_import_lxd_image qc_create_lxd_container
}

# --------------------------  MAIN

lkm_confirm "Install Juju, ZFS and LXD?" true
[ $? -eq 0 ] && qc_install_juju_zfs_lxd && { lkm_notify2 "You must log out and log back in to continue."; return 1; }

lkm_confirm "Create ZFS pool and init Juju?" true
[ $? -eq 0 ] && qc_init_juju_lxd

# not a server
if [ "$QC_IS_SERVER" -eq 1 ]; then
  lkm_confirm "Import ubuntu image?" true
  [ $? -eq 0 ] && qc_import_lxd_image

  lkm_confirm "Create lxd container from ubuntu image?" true
  [ $? -eq 0 ] && qc_create_lxd_container

  # Juju2 isn't ready yet

  #    lkm_confirm "Deploy WordPress to container using Juju" true
  #    [ $? -eq 0 ] && qc_deploy_wordpress

  #    lkm_notify2 "Use your browser to create a WordPress user before proceeding."

  #    lkm_confirm "Add memcached relation to WordPress?" true
  #    [ $? -eq 0 ] && qc_add_memcached
fi

qc_reset

} # this ensures the entire script is downloaded #
