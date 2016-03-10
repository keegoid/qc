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

confirm "Create Alpine Linux image for LXD?" true
[ "$?" -eq 0 ] && create_alpine_lxd_image  "https://github.com/saghul/lxd-alpine-builder.git" \
                                           "$HOME/.uqc/lxd/lxd-alpine-builder/"

confirm "Create LXD container from newly created image?" true
[ "$?" -eq 0 ] && create_lxd_container

