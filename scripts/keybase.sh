#!/bin/bash
echo "# --------------------------------------------"
echo "# Install Keybase command line client.        "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

KEYBASE_URL='https://dist.keybase.io/linux/deb/keybase-latest-amd64.deb'

# --------------------------  INSTALL KEYBASE (fun!)

# install the keybase cli client
install_keybase() {
    if not_installed "keybase"; then
        # change to tmp directory to download file and then back to original directory
        cd /tmp
        curl -O "$KEYBASE_URL" && sudo dpkg -i keybase-latest-amd64.deb
        cd - >/dev/null
    else
        notify "keybase is already installed"
    fi
}

# --------------------------  MAIN

confirm "Install Keybase?" true
[ "$?" -eq 0 ] && install_keybase
