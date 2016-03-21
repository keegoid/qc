#!/bin/bash
echo "# --------------------------------------------"
echo "# Install LXD, create Alpine Linux LXD image  "
echo "# and container, configure container with     "
echo "# shared directory and ssh access.            "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

[ -z "$REPOS" ] && read -ep "Directory to use for repositories: ~/" -i "Dropbox/Repos" REPOS
SELECTED_CONTAINER=

# --------------------------  INSTALL LXD/LXC

# install Juju, ZFS and LXD
install_juju_zfs_lxd() {
    if not_installed juju2; then
        sudo apt-add-repository -y ppa:juju/devel
        sudo apt-get update
        install_apt juju2
#        [ "$IS_SERVER" -eq 0 ] && install_apt juju || install_apt juju-local
    else
        notify "Juju2 is already installed"
    fi
    install_apt "zfsutils-linux lxd criu"

    RET="$?"
    debug
}

# --------------------------  INIT JUJU AND LXD WITH ZFS

init_juju_lxd() {
    notify3 "At this point you could exit this script and set up your ZFS pool manually on some physical hard drives per instructions at:"
    notify3 "http://goo.gl/z6Xg5Z and https://goo.gl/1e3a5e"
    confirm "Create a sparse, loopback file for the ZFS pool instead?" true
    # create zfs block
    [ "$?" -eq 0 ] && sudo lxd init

    # set compression and turn off dedup
    read -ep "Enter the name you used for your zpool: " zpool_name
    sudo zfs set compression=on "$zpool_name"
    sudo zfs set compression=lz4 "$zpool_name"
    sudo zfs set dedup=off "$zpool_name"
    success "set compression to lz4 and disabled dedup on $zpool_name"

    # add cron job to scrub zpool weekly
    echo -e "#!/bin/sh\n/sbin/zpool scrub $zpool_name" | sudo tee /etc/cron.weekly/zfsscrub
    sudo chmod +x /etc/cron.weekly/zfsscrub

    # limit memory usage by zpool
    echo -e "# Limit arc to 1GB\noptions zfs zfs_arc_max=1073741824" | sudo tee /etc/modprobe.d/zfs.conf

     # verify zfs
    sudo zpool list
    sudo zpool status

    # set Juju to work with LXD
#    pause "Press [Enter] to init Juju"
#    juju init
#    mv -n ~/.juju/environments.yaml ~/.juju/environments-old.yaml
#    echo -e "default: local\n\nenvironments:\n\n\tlxd:\n\ttype: lxd" | tee ~/.juju/environments.yaml
#    juju init --show
#    juju switch lxd
#    juju bootstrap --upload-tools

    RET="$?"
    debug
}

# --------------------------  UBUNTU IMAGE

# import base ubuntu image for LXD
import_lxd_image() {
    not_installed lxd && install_lxd

    # copy image from remote server to local image store
    lxd-images import ubuntu trusty amd64 --sync --alias ubuntu-trusty && success "successfully imported ubuntu image to lxd image store"

    RET="$?"
    debug
}

# --------------------------  HOST NAME

# add ip address and host name to /etc/hosts
# $1 -> host name
set_hosts() {
    lxc list
    read -ep "Type an existing container name to use for ${1}: " SELECTED_CONTAINER

    # add container's ip to /etc/hosts
    pause "Press [Enter] to add $1 to /etc/hosts"
    local ipv4=$(lxc list | grep "$SELECTED_CONTAINER" | cut -d "|" -f 4 | cut -d " " -f 2)
    # remove entry if it already exists
    if cat /etc/hosts | grep "$1" >/dev/null; then
        sudo sed -i.bak "/$1/d" /etc/hosts
    fi
    # wait for ip address to get assigned to container
    while [ -z "$ipv4" ]; do
        notify3 "The container hasn't been assigned an IP address yet."
        pause "Press [Enter] to try again" true
        ipv4=$(lxc list | grep $SELECTED_CONTAINER | cut -d "|" -f 4 | cut -d " " -f 2)
    done
    # add new hosts entry
    [ -n "$ipv4" ] && echo -e "${ipv4}\t${1}" | sudo tee --append /etc/hosts && success "successfully added ${ipv4} and ${1} to /etc/hosts" || notify2 "Couldn't add ${1} to /etc/hosts, missing IP address on container."

    RET="$?"
    debug
}

# --------------------------  SHARED DIRECTORY

# create shared directory to sync files between host and container
# $1 -> host name
set_shared_directory() {
    # set syncing directory paths
    read -ep "Choose a source directory on host to sync: ~/${REPOS}/" -i "sites/${1}/site" relative_source
    read -ep "Choose a target directory in container to sync: /" -i "var/www/${1}/public_html" target_dir
    source_dir="$HOME/${REPOS}/$relative_source"
    target_dir="/${target_dir}"

    pause "Press [Enter] to configure shared directory between host and container"
    # make source and target directories and configure with proper permissions
    mkdir -p "$source_dir"
    sudo chgrp 165536 "$source_dir"
    sudo chmod g+s "$source_dir"
    #   sudo setfacl -d -m u:lxd:rwx,u:$(whoami):rwx,u:165536:rwx,g:lxd:rwx,g:$(whoami):rwx,g:165536:rwx "$source_dir"
    lxc exec "${SELECTED_CONTAINER}" -- su - root -c "mkdir -p $target_dir"
    # check if device already exists and remove it if it does
    if lxc config device list "${SELECTED_CONTAINER}" >/dev/null | grep "shared-${1}"; then
        lxc config device remove "${SELECTED_CONTAINER}" "shared-${1}"
    fi
    # add new device for shared directory
    lxc config device add "${SELECTED_CONTAINER}" "shared-${1}" disk source="$source_dir" path="$target_dir" && success "Successfully configured syncing of $source_dir on host with $target_dir in container."

    RET="$?"
    debug
}

# --------------------------  SSH KEY

# add ssh key to authorized keys in container
set_authorized_key() {
    # if no ssh key, generate one
    [ -f "$HOME/.ssh/id_rsa.pub" ] || gen_ssh_key $HOME/.ssh $(whoami)
    pause "Press [Enter] to copy public your ssh key to \"authorized_keys\" in container"
    # make .ssh directory if it doesn't exist
    lxc exec "${SELECTED_CONTAINER}" -- su - root -c "mkdir -p .ssh"
    # push public ssh key to container
    lxc file push "$HOME/.ssh/id_rsa.pub" "${SELECTED_CONTAINER}/root/.ssh/authorized_keys" && success "Successfully added ssh key to ${SELECTED_CONTAINER}."

    RET="$?"
    debug
}

# --------------------------  CREATE CONTAINER

# create new lxd container from latest image
create_lxd_container() {
    local selected_image
    local host_name
    local relative_source
    local target_dir
    local source_dir
    local target_dir_root

    # select an image and choose a container name
    lxc image list
    read -ep "Select an image to use for the new container: " -i 'ubuntu-trusty' selected_image
    read -ep "Enter a host name to use with /etc/hosts: " -i 'wordpress.dev' host_name

    # create and start container
    lxc launch "$selected_image"

    set_hosts "$host_name"

    set_shared_directory "$host_name"

    set_authorized_key

    # install and run easyengine inside ubuntu container
#    lxc exec "${SELECTED_CONTAINER}" -- su - root -c "wget -qO ee rt.cx/ee && sudo bash ee"
#    lxc exec "${SELECTED_CONTAINER}" -- su - root -c "sudo ee site create ${host_name} --wpfc"

    RET="$?"
    debug
}

# --------------------------  DEPLOY WORDPRESS

# deploy WordPress to container using Juju
deploy_wordpress() {
    local git_repo

    juju deploy mysql
    juju deploy memcached
    juju deploy wordpress
#    watch juju status
    juju add-relation wordpress mysql
    juju expose wordpress
    juju set wordpress tuning=optimized

    # optionally set wp-content to git repository
    confirm "Use a git repository for wp-content?" true
    [ "$?" -eq 0 ] && notify3 "Format: git@host:path/repo.git or http://host/path/repo.git" && read -ep "Enter a git repository: " git_repo && juju set wordpress wp-content="$git_repo"

    RET="$?"
    debug
}

# add memcached relation
add_memcached() {
    # configure WordPress and add first user, then we can add memcached relation
    juju add-relation memcached wordpress

    RET="$?"
    debug
}

# --------------------------  MAIN

confirm "Install Juju, ZFS and LXD?" true
[ "$?" -eq 0 ] && install_juju_zfs_lxd && { notify2 "You must log out and log back in to continue."; return 1; }

confirm "Create ZFS pool and init Juju?" true
[ "$?" -eq 0 ] && init_juju_lxd

# not a server
if [ "$IS_SERVER" -eq 1 ]; then
    confirm "Import ubuntu image?" true
    [ "$?" -eq 0 ] && import_lxd_image

    confirm "Create lxd container from ubuntu image?" true
    [ "$?" -eq 0 ] && create_lxd_container

# Juju2 isn't ready yet

#    confirm "Deploy WordPress to container using Juju" true
#    [ "$?" -eq 0 ] && deploy_wordpress

#    notify2 "Use your browser to create a WordPress user before proceeding."

#    confirm "Add memcached relation to WordPress?" true
#    [ "$?" -eq 0 ] && add_memcached
fi

