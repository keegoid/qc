#!/bin/bash
echo "# --------------------------------------------"
echo "# Install and update programs.                "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Company: KM Authorized LLC                  "
echo "# Website: http://kmauthorized.com            "
echo "#                                             "
echo "# MIT: http://kma.mit-license.org             "
echo "# --------------------------------------------"

# update programs maintained by the package manager
pause "Press enter to update Linux..."
apt-get -y install upgrade

# install programs with apt-get
install_apt "$APT_PROGRAMS"

# install gems
install_gem "$GEM_PROGRAMS"

# install pips
install_pip "$PIP_PROGRAMS"

# install npms
install_npm "$NPM_PROGRAMS" true

# install keybase
pause "Press enter to run the keybase installer..."
keybase-installer
pause "Press enter to test the keybase command..."
keybase version

if $DROPBOX; then
   echo
   echo "To install Dropbox, please do so manually at: "
   echo "https://www.dropbox.com/install?os=lnx"
fi

echo
script_name "          done with "
echo "*********************************************"
