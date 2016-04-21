#!/bin/bash
# --------------------------------------------
# Install or update virtual machine apps.
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keeganmullaney@gmail.com
# License: keegoid.mit-license.org
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  MAIN

lkm_confirm "install Virtualbox?" true
[ $? -eq 0 ] && lkm_install_apt virtualbox

lkm_confirm "install Vagrant?" true
[ $? -eq 0 ] && lkm_install_apt vagrant

} # this ensures the entire script is downloaded #
