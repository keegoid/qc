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

