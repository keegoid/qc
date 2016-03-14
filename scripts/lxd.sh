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
LXD_IMAGE=
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

# create a base alpine linux image for LXD
create_alpine_lxd_image() {
    local repo_url="$1"
    local repo_name=$(trim_longest_left_pattern "$2" "/")
    local repo_dir=$(trim_shortest_right_pattern "$2" "/")
    local image_name="alpine-latest"
    local image_cnt

    [ -z "$repo_name" ] && repo_name=$(trim_longest_left_pattern "$repo_dir" "/")

    # update or clone alpine-lxd-image repo
    if [ -d "$repo_dir" ]; then
        notify "already set $repo_name"
        cd $repo_dir && echo "checking for updates: $repo_name" && git pull && cd - >/dev/null
    else
        pause "Press [Enter] to configure $repo_name" true
        git clone "$repo_url" "$repo_dir" && success "configured: $repo_name"
    fi

    not_installed lxd && install_lxd

    # count number of matches for alpine-latest and add one
    image_cnt=$(lxc image list | grep -c $image_name)
    LXD_IMAGE="$image_name-$image_cnt"

    cd "$repo_dir"
    # remove any previous images
    sudo rm alpine-v*.tar.gz >/dev/null 2>&1
    # download and build the latest alpine image
    sudo ./build-alpine
    # set permissions
    sudo chmod 664 alpine-v*.tar.gz
    # add newly created image to lxc
    [ -f alpine-v*.tar.gz ] && lxc image import alpine-v*.tar.gz --alias "$LXD_IMAGE" && success "successfully created alpine linux lxd image and imported into lxc"
    cd - >/dev/null
}

# --------------------------  CREATE CONTAINER

# create new lxd container from latest image
create_lxd_container() {
    local image_name="alpine-latest"
    local image_cnt=`expr $(lxc image list | grep -c $image_name) - 1`
    local selected_image
    local container_name
    local host_name

    # set image name if not already set
    [ -z "$LXD_IMAGE" ] && LXD_IMAGE="$image_name-$image_cnt"

    # select an image and choose a container name
    lxc image list
    read -ep "Select an image to use for the new container: " -i "$LXD_IMAGE" selected_image
    read -ep "Enter a container name to use with $selected_image: " -i "alpine-wp-${image_cnt}" container_name
    read -ep "Enter a host name to use with /etc/hosts: " -i "${container_name}.dev" host_name

    # create and start container
    lxc launch "$selected_image" "$container_name"

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
    local image_cnt=`expr $(lxc image list | grep -c alpine-latest) - 1`
    local selected_container
    local relative_source
    local target_dir
    local source_dir
    local target_dir_root

    # set container name if not already set
    [ -z "$LXD_CONTAINER" ] && LXD_CONTAINER="alpine-wp-${image_cnt}"

    # select a container and set syncing directory paths
    lxc list
    read -ep "Select a container to configure: " -i "$LXD_CONTAINER" selected_container
    read -ep "Choose a source directory on host to sync: ~/${REPOS}/" -i "sites/${selected_container}/site" relative_source
    read -ep "Choose a target directory in container to sync: /" -i "srv/www/${selected_container}/current" target_dir
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

confirm "Create Alpine Linux image for LXD?" true
[ "$?" -eq 0 ] && create_alpine_lxd_image  "https://github.com/saghul/lxd-alpine-builder.git" \
                                           "$HOME/.quick-config/lxd/lxd-alpine-builder/"

confirm "Create LXD container from Alpine image?" true
[ "$?" -eq 0 ] && create_lxd_container

confirm "Configure LXD container for syncing and ssh with host?" true
[ "$?" -eq 0 ] && configure_lxd_container

