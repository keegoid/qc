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

# --------------------------  LXD IMAGE & CONTAINER

confirm "Create Alpine Linux image for LXD?" true
[ "$?" -eq 0 ] && create_alpine_lxd_image  "https://github.com/saghul/lxd-alpine-builder.git" \
                                           "$HOME/.uqc/lxd/lxd-alpine-builder/"

confirm "Create LXD container from newly created image?" true
[ "$?" -eq 0 ] && create_lxd_container

