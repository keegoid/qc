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

# --------------------------  64-BIT ARCHITECTURE

UPDATE=0
if [ "$(dpkg --print-foreign-architectures)" = "i386" ]; then
   pause "Press [Enter] to purge all i386 packages and remove the i386 architecture" true
   sudo apt-get purge ".*:i386" && sudo dpkg --remove-architecture i386 && sudo apt-get update && success "Success, goodbye i386!" && UPDATE=1
fi

# --------------------------  PROMPT FOR PROGRAMS

if [ "$IS_SERVER" -eq 0 ]; then
   read -ep "Enter apps to install with apt-get: " -i 'gnupg2 lynx openssh-server xclip vim-gtk' APTS
else
   read -ep "Enter apps to install with apt-get: " -i 'autojump build-essential cmake checkinstall cvs dconf-cli deluge git-core gnupg2 gufw lynx mercurial nautilus-open-terminal subversion silversearcher-ag tmux x11vnc xclip vim-gtk vlc' APTS
   read -ep "Enter apps to install with gem: " -i 'gist' GEMS
   read -ep "Enter apps to install with npm: " -i 'doctoc' NPMS
   read -ep "Enter apps to install with pip: " -i 'jrnl[encrypted]' PIPS
fi

# --------------------------  ARRAY ASSIGNMENTS

# add packages, gems, npms and pips to check list arrays
apt_check_list+=($APTS)
gem_check_list+=($GEMS)
npm_check_list+=($NPMS)
pip_check_list+=($PIPS)

# --------------------------  INSTALL PROGRAMS

# install packages, gems, npms and pips
apt_install "$UPDATE"
gem_install
npm_install
pip_install

# install keybase
confirm "Install Keybase?" true
install_keybase

# install spf13-vim
install_spf13_vim

