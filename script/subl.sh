#!/bin/bash
# --------------------------------------------
# Install and configure Sublime Text.
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keeganmullaney@gmail.com
# License: keegoid.mit-license.org
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  INSTALL THE BEST TEXT EDITOR IN THE WORLD

# install Sublime Text
qc_install_subl() {
  local subl_v
  [ -z "$subl_v" ] && read -rep "Sublime Text 3 version to use: " -i "3126" subl_v
  local subl_url="https://download.sublimetext.com/sublime-text_build-${subl_v}_amd64.deb"

  if lkm_not_installed "subl"; then
    (
      # change to tmp directory to download file within subshell
      cd /tmp || exit
      echo "downloading subl..."
      curl -O "$subl_url" && sudo dpkg -i "sublime-text_build-${subl_v}_amd64.deb" && lkm_success "successfully installed: subl"
    )
    # set sublime-text as default text editor
    sudo sed -i.bak "s/gedit/sublime_text/" /etc/gnome/defaults.list
  else
    lkm_notify "subl is already installed"
  fi

  lkm_notify "Make sure to install Package Control so subl can install any packages listed in your User directory. It can be installed from https://packagecontrol.io/installation"
  lkm_notify2 "Recommend installing the Material Theme package for Sublime Text 3 from https://github.com/equinusocio/material-theme"
}

# --------------------------  MAIN

lkm_confirm "Install Sublime Text?" true
[ $? -eq 0 ] && qc_install_subl

unset -f qc_install_subl

} # this ensures the entire script is downloaded #
