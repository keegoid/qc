#!/bin/bash
echo "# --------------------------------------------"
echo "# Install requirments for WordPress dev.      "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# wordpress development
VVV_REQS=$(confirm "install virtualbox and vagrant for VVV?" false)
if [ "$VVV_REQS" = true ]; then
   install_virtualbox
   install_vagrant
   VVV_GO=$(confirm "clone VVV and VV for WordPress development?" false)
   if [ "$VVV_GO" = true ]; then
      clone_vvv
      clone_vv
   fi
fi

