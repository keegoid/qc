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

# --------------------------  DEFAULT APT PACKAGES

DEFAULT_SERVER_LIST='gnupg2 lynx openssh-server xclip vim-gtk'
DEFAULT_WORKSTATION_LIST='autojump deluge gnupg2 gufw lynx nautilus-open-terminal silversearcher-ag tmux x11vnc xclip vim-gtk vlc'
DEFAULT_DEV_LIST='build-essential cmake checkinstall cvs dconf-cli git-core mercurial subversion'
RUBY_DEPENDENCIES_LIST='libffi-dev libreadline-dev libsqlite3-dev libssl-dev libxml2-dev libxslt1-dev libyaml-dev python-software-properties sqlite3libcurl4-openssl-dev zlib1g-dev'

# --------------------------  PROMPT FOR PROGRAMS

if [ "$IS_SERVER" -eq 0 ]; then
   read -ep "Enter apps to install with apt-get: " -i "$SERVER_APTS_LIST" APTS
else
   notify2 "You'll have a chance to modify the following default packages prior to installation."
   echo
   echo -e "${TEAL_BLACK} WORKSTATION: ${NONE_WHITE} $DEFAULT_WORKSTATION_LIST"
   echo -e "${PURPLE_BLACK} DEVELOPER: ${NONE_WHITE} $DEFAULT_DEV_LIST"
   echo -e "${BLUE_BLACK} RUBY DEPENDENCIES: ${NONE_WHITE} $RUBY_DEPENDENCIES_LIST"
   echo
   read -ep "Enter workstation apps to install: " -i "$DEFAULT_WORKSTATION_LIST" APTS1
   read -ep "Enter developer apps to install: " -i "$DEFAULT_DEV_LIST" APTS2
   read -ep "Enter ruby dependencies to install: " -i "$RUBY_DEPENDENCIES_LIST" APTS3
   read -ep "Enter apps to install with gem: " -i 'bundler gist' GEMS
   read -ep "Enter apps to install with npm: " -i 'doctoc' NPMS
   read -ep "Enter apps to install with pip: " -i 'jrnl[encrypted]' PIPS
fi

# --------------------------  ARRAY ASSIGNMENTS

# add packages, gems, npms and pips to check list arrays
apt_check_list+=($APTS1)
apt_check_list+=($APTS2)
apt_check_list+=($APTS3)
gem_check_list+=($GEMS)
npm_check_list+=($NPMS)
pip_check_list+=($PIPS)

# --------------------------  INSTALL FROM PACKAGE MANAGER

apt_install "$UPDATE"

# --------------------------  INSTALL FROM CUSTOM SCRIPTS

confirm "Install ruby?" true
[ "$?" -eq 0 ] && install_ruby

confirm "Install keybase?" true
[ "$?" -eq 0 ] && install_keybase

confirm "Install spf13-vim?" true
[ "$?" -eq 0 ] && install_spf13_vim

confirm "Install flockport?" true
[ "$?" -eq 0 ] && install_flockport

# --------------------------  INSTALL FROM OTHER PACKAGE MANAGERS

gem_install
npm_install
pip_install

