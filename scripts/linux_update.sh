#!/bin/bash
echo "# --------------------------------------------"
echo "# Install and update programs.                "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# update programs maintained by the package manager
pause "Press [Enter] to update Ubuntu sources" true
sudo apt-get -y update
pause "Press [Enter] to upgrade programs" true
sudo apt-get -y upgrade

# install programs with apt-get
install_apt "$APT_PROGRAMS"

# install gems
#install_gem "$GEM_PROGRAMS"

# install pips
install_pip "$PIP_PROGRAMS"

# install npms
install_npm "$NPM_PROGRAMS" true

# install keybase
install_keybase

