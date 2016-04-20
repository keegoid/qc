#!/bin/bash
echo "# --------------------------------------------"
echo "# Install or update virtual machine apps.     "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: keegoid.com                        "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"


# --------------------------  MAIN

confirm "install Virtualbox?" true
[ $? -eq 0 ] && install_apt virtualbox

confirm "install Vagrant?" true
[ $? -eq 0 ] && install_apt vagrant
