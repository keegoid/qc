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
LXD_CONTAINER=

# --------------------------  INSTALL LXD/LXC

# install or update LXD for LXC containers
install_lxd() {
    program_must_exist lxc
    if not_installed lxd; then
        sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable && sudo sed -i.bak -e "/trusty-backports/ s/^# //" /etc/apt/sources.list && sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y -t trusty-backports install lxd criu && success "successfuly installed: LXD (\"lex-dee\")" && notify2 "You must log out and log back in for lxc command to work."
    else
        notify "already installed LXD"
    fi
}

# --------------------------  BUILD ALPINE LINUX IMAGE

# copy base ubuntu image for LXD
copy_lxd_image() {
    not_installed lxd && install_lxd

    # copy image from remote server to local image store
    lxc image copy ubuntu: local: --alias ubuntu && success "successfully copied ubuntu image to lxd image store"
}

# --------------------------  CREATE CONTAINER

# create new lxd container from latest image
create_lxd_container() {
    local selected_image
    local container_name
    local host_name

    # select an image and choose a container name
    lxc image list
    read -ep "Select an image to use for the new container: " -i 'ubuntu' selected_image
    read -ep "Enter a host name to use with /etc/hosts: " -i 'example.dev' host_name

    # create and start container
    lxc launch "$selected_image"

    lxc list
    read -ep "Select a container to use for ${host_name}: " container_name

    # add container's ip to /etc/hosts
    pause "Press [Enter] to add $host_name to /etc/hosts"
    local ipv4=$(lxc list | grep $container_name | cut -d "|" -f 4 | cut -d " " -f 2)
    # remove entry if it already exists
    if cat /etc/hosts | grep "$host_name" >/dev/null; then
        sudo sed -i.bak "/$host_name/d" /etc/hosts
    fi
    # wait for ip address to get assigned to container
    while [ -z "$ipv4" ]; do
        notify3 "The container hasn't been assigned an IP address yet."
        pause "Press [Enter] to try again" true
        ipv4=$(lxc list | grep $container_name | cut -d "|" -f 4 | cut -d " " -f 2)
    done
    # add new hosts entry
    [ -n "$ipv4" ] && echo -e "${ipv4}\t${host_name}" | sudo tee --append /etc/hosts && success "successfully added ${ipv4} and ${host_name} to /etc/hosts" || notify2 "Couldn't add ${host_name} to /etc/hosts, missing IP address on container."

    # set global container name variable
    LXD_CONTAINER="$container_name"

    RET="$?"
    debug
}

# --------------------------  CONFIGURE CONTAINER

# configure lxd container for syncing and ssh with host
configure_lxd_container() {
    local selected_container="$LXD_CONTAINER"
    local relative_source
    local target_dir
    local source_dir
    local target_dir_root

    # set container name if not already set
    if [ -z "$LXD_CONTAINER" ]; then
        lxc list
        read -ep "Select a container to configure: " selected_container
    fi

    # set syncing directory paths
    read -ep "Choose a source directory on host to sync: ~/${REPOS}/" -i "sites/${selected_container}/site" relative_source
    read -ep "Choose a target directory in container to sync: /" -i "var/www/${selected_container}/current" target_dir
    source_dir="$HOME/${REPOS}/$relative_source"
    target_dir="/${target_dir}"

    pause "Press [Enter] to configure shared directory between host and container"
    # make source and target directories and configure with proper permissions
    mkdir -p "$source_dir"
    sudo chgrp 165536 "$source_dir"
    sudo chmod g+s "$source_dir"
    #   sudo setfacl -d -m u:lxd:rwx,u:$(logname):rwx,u:165536:rwx,g:lxd:rwx,g:$(logname):rwx,g:165536:rwx "$source_dir"
    lxc exec "${selected_container}" -- su - root -c "mkdir -p $target_dir"
    # check if device already exists and remove it if it does
    if lxc config device list "${selected_container}" >/dev/null | grep "shared-dir-${image_cnt}"; then
        lxc config device remove "${selected_container}" "shared-dir-${image_cnt}"
    fi
    # add new device for shared directory
    lxc config device add "${selected_container}" "shared-dir-${image_cnt}" disk source="$source_dir" path="$target_dir" && success "Successfully configured syncing of $source_dir on host with $target_dir in container."

    # if not a server
    if [ "$IS_SERVER" -eq 1 ]; then
        # if no ssh key, generate one
        [ -f "$HOME/.ssh/id_rsa.pub" ] || gen_ssh_key $HOME/.ssh $(logname)
        pause "Press [Enter] to copy public your ssh key to \"authorized_keys\" in container"
        # make .ssh directory if it doesn't exist
        lxc exec "${selected_container}" -- su - root -c "mkdir -p .ssh"
        # push public ssh key to container
        lxc file push "$HOME/.ssh/id_rsa.pub" "${selected_container}/root/.ssh/authorized_keys" && success "Successfully added ssh key to ${selected_container}."
    fi

    RET="$?"
    debug
}

# --------------------------  MAIN

pause "" true

confirm "Install LXD?" true
[ "$?" -eq 0 ] && install_lxd

[ $(lxc version) ] || { notify2 "You must log out and log back in to continue."; return 1; }

confirm "Copy ubuntu image to LXD?" true
[ "$?" -eq 0 ] && copy_lxd_image

confirm "Create LXD container from Alpine image?" true
[ "$?" -eq 0 ] && create_lxd_container

confirm "Configure LXD container for syncing and ssh with host?" true
[ "$?" -eq 0 ] && configure_lxd_container

