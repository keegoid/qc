#!/bin/bash
echo "# --------------------------------------------"
echo "# Create Alpine Linux LXD image and container "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  LXC COMMAND

[ $(lxc version) ] || { notify2 "You must log out and log back in before running this script."; return 1; }

# --------------------------  LXD IMAGE & CONTAINER

LXD_IMAGE=
confirm "Create Alpine Linux image for LXD?" true
[ "$?" -eq 0 ] && create_alpine_lxd_image  "https://github.com/saghul/lxd-alpine-builder.git" \
                                           "$HOME/.quick-config/lxd/lxd-alpine-builder/"

LXD_CONTAINER=
confirm "Create LXD container from Alpine image?" true
[ "$?" -eq 0 ] && create_lxd_container

confirm "Configure LXD container for syncing and ssh with host?" true
[ "$?" -eq 0 ] && configure_lxd_container "$REPOS" "$IS_SERVER"
