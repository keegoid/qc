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
UPDATE=0
if [ "$(dpkg --print-foreign-architectures)" = "i386" ]; then
   pause "Press [Enter] to purge all i386 packages and remove the i386 architecture" true
   sudo apt-get purge ".*:i386" && sudo dpkg --remove-architecture i386 && sudo apt-get update && echo "Success, goodbye i386!" && UPDATE=1
fi

if [ $IS_SERVER -eq 0 ]; then
   read -ep "Enter apps to install with apt-get: " -i 'gnupg2 lynx openssh-server xclip vim' APTS
else
   read -ep "Enter apps to install with apt-get: " -i 'autojump build-essential cmake checkinstall cvs deluge git-core gnupg2 gufw lynx mercurial nautilus-open-terminal subversion silversearcher-ag x11vnc xclip vim-gtk vlc' APTS
   read -ep "Enter apps to install with gem: " -i 'gist' GEMS
   read -ep "Enter apps to install with npm: " -i 'doctoc' NPMS
   read -ep "Enter apps to install with pip: " -i 'jrnl[encrypted]' PIPS
fi

# add packages, gems, npms and pips to check list arrays
apt_check_list+=($APTS)
gem_check_list+=($GEMS)
npm_check_list+=($NPMS)
pip_check_list+=($PIPS)

# install packages, gems, npms and pips
apt_install $UPDATE
gem_install
npm_install
pip_install

# install keybase
install_keybase

# restart nautilus
nautilus -q && nautilus &
