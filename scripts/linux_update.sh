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
   notify "Server packages to install (none to skip)"
   read -ep "   : " -i "$SERVER_APTS_LIST"         APTS1
else
   notify2 "The following default packages can be modified prior to installation."
   echo
   echo "WORKSTATION"
   echo "DEVELOPER"
   echo "RUBY DEPENDENCIES"
   echo "GEMs, NPMs, PIPs"
   echo
   notify "Workstation packages to install (delete all to skip)"
   read -ep "   : " -i "$DEFAULT_WORKSTATION_LIST" APTS1
   echo
   notify "Developer packages to install"
   read -ep "   : " -i "$DEFAULT_DEV_LIST"         APTS2
   echo
   notify "Ruby dependencies to install"
   read -ep "   : " -i "$RUBY_DEPENDENCIES_LIST"   APTS3
   echo
   notify "Packages to install with gem"
   read -ep "   : " -i 'bundler gist'              GEMS
   echo
   notify "Packages to install with npm"
   read -ep "   : " -i 'doctoc'                    NPMS
   echo
   notify "Packages to install with pip"
   read -ep "   : " -i 'jrnl[encrypted]'           PIPS
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

echo
confirm "Install ruby with rbenv and ruby-build?" true
[ "$?" -eq 0 ] && install_rbenv_ruby

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

