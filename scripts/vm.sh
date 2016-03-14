#!/bin/bash
echo "# --------------------------------------------"
echo "# Install or update virtual machine apps.     "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

VIRTUALBOX_V='5.0'
VAGRANT_V='1.8.1'

VIRTUALBOX_URL='http://download.virtualbox.org/virtualbox/debian'
VAGRANT_URL='https://releases.hashicorp.com/vagrant/${VAGRANT_V}/vagrant_${VAGRANT_V}_x86_64.deb'

# --------------------------  INSTALL VIRTUAL MACHINE STUFF

# install newer version of virtualbox
install_virtualbox() {
    if not_installed "virtualbox-${VIRTUALBOX_V}"; then
        # add virtualbox to sources list if not already there
        if ! grep -q "virtualbox" /etc/apt/sources.list; then
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
            echo "deb $VIRTUALBOX_URL trusty contrib" | sudo tee --append /etc/apt/sources.list
        fi
        # add signing key
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
        # update sources and install the latest virtualbox
        sudo apt-get update
        install_apt "virtualbox-${VIRTUALBOX_V}"
    fi

    RET="$?"
    debug
}

# install newer version of vagrant
install_vagrant() {
    if not_installed "vagrant"; then
        # change to tmp directory to download file and then back to original directory
        cd /tmp
        echo "downloading vagrant..."
        curl -O "$VAGRANT_URL" && sudo dpkg -i "vagrant_${VAGRANT_V}_x86_64.deb" && success "successfully installed: vagrant"
        cd - >/dev/null
    fi
    # install vagrant-hostsupdater
    [ -z "$(vagrant plugin list | grep hostsupdater)" ] && vagrant plugin install vagrant-hostsupdater
    # install vagrant-triggers
    [ -z "$(vagrant plugin list | grep triggers)" ] && vagrant plugin install vagrant-triggers

    RET="$?"
    debug
}

# --------------------------  MAIN

pause "" true

confirm "install Virtualbox?" true
[ "$?" -eq 0 ] && install_virtualbox

confirm "install Vagrant?" true
[ "$?" -eq 0 ] && install_vagrant
