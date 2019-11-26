#!/bin/bash
# --------------------------------------------
# Install Keybase command line client.
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keegan@kmauthorized.com
# License: keegoid.mit-license.org
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  INSTALL KEYBASE (fun!)

# install the keybase cli client
qc_install_keybase() {
  local keybase_url='https://dist.keybase.io/linux/deb/keybase-latest-amd64.deb'

  if lkm_not_installed "keybase"; then
    (
      # change to tmp directory to download file within subshell
      cd /tmp || exit
      curl -O "$keybase_url" && sudo dpkg -i keybase-latest-amd64.deb
    )
  else
    lkm_notify "keybase is already installed"
  fi
}

# --------------------------  MAIN

lkm_confirm "Install Keybase?" true
[ $? -eq 0 ] && qc_install_keybase

} # this ensures the entire script is downloaded #
