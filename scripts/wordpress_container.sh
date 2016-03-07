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

pause "" true
# wordpress development
if confirm "install virtualbox and vagrant for VVV?" true; then
   install_virtualbox
   install_vagrant
   if confirm "clone VVV and VV for WordPress development?" true; then
      read -ep "Directory to use for repositories: ~/" -i "Dropbox/Repos" REPOS
      clone_vvv "$REPOS"
      clone_vv "$REPOS"
   fi
fi

