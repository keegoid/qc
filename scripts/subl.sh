#!/bin/bash
echo "# --------------------------------------------"
echo "# Install and configure Sublime Text.         "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

SUBL_V='3103'
SUBL_URL="https://download.sublimetext.com/sublime-text_build-${SUBL_V}_amd64.deb"

# --------------------------  INSTALL THE BEST TEXT EDITOR IN THE WORLD

# install Sublime Text
install_subl() {
   if not_installed "subl"; then
      # change to tmp directory to download file and then back to original directory
      cd /tmp
      echo "downloading subl..."
      curl -O "$SUBL_URL" && sudo dpkg -i "sublime-text_build-${SUBL_V}_amd64.deb" && success "successfully installed: subl"
      cd - >/dev/null
      # set sublime-text as default text editor
      sudo sed -i.bak "s/gedit/sublime_text/" /etc/gnome/defaults.list
   else
      notify "subl is already installed"
   fi
}

# --------------------------  MAIN

pause "" true

confirm "Install Sublime Text?" true
[ "$?" -eq 0 ] && install_subl
