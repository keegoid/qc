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

# remove i386 architecture from sources list
if [ "$(dpkg --print-foreign-architectures)" = "i386" ]; then
   pause "Press [Enter] to purge all i386 packages and remove the i386 architecture" true
   sudo apt-get purge ".*:i386" && sudo dpkg --remove-architecture i386 && sudo apt-get update && echo "Success, goodbye i386!"
fi

if [ $IS_SERVER -eq 0 ]; then
   read -ep "Enter apps to install with apt-get: " -i 'gnupg2 lynx openssh-server xclip vim' APT_PROGRAMS
else
   read -ep "Enter apps to install with apt-get: " -i 'autojump deluge gnupg2 gufw lynx nautilus-open-terminal silversearcher-ag x11vnc xclip vim vlc' APT_PROGRAMS
   read -ep "Enter apps to install with pip: " -i 'jrnl[encrypted]' PIP_PROGRAMS
   read -ep "Enter apps to install with npm: " -i 'doctoc' NPM_PROGRAMS
   read -ep "Enter apps to install with gem: " -i 'gist' GEM_PROGRAMS
fi

# add programs to check list array
apt_package_check_list+=($APT_PROGRAMS)

# install programs with apt-get
package_install

# install gems
install_gem "$GEM_PROGRAMS"

# install pips
install_pip "$PIP_PROGRAMS"

# install npms
install_npm "$NPM_PROGRAMS" true

# install keybase
install_keybase

