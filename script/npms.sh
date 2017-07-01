#!/bin/bash
# --------------------------------------------
# Install / update Nodejs and NPMs via NVM
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keeganmullaney@gmail.com
# License: keegoid.mit-license.org
#
# Attributions:
# package install functions & lists
# github.com/Varying-Vagrant-Vagrants/VVV/
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  SETUP PARAMETERS
[ -z "$NVM_V" ] && NVM_V=0.33.2

# --------------------------  MISSING PROGRAM CHECKS

# install lists (perform install)
npm_install_list=()

# check lists (check if installed)
npm_check_list=()

# --------------------------  CUSTOM INSTALL SCRIPTS

# install the long term support version of Node.js via NVM
qc_nvm() {
  # install NVM
  curl -o- "https://raw.githubusercontent.com/creationix/nvm/v${NVM_V}/install.sh" | bash

  # source nvm
  # shellcheck source=/dev/null
  . ~/.nvm/nvm.sh

  # make sure nvm is installed
  lkm_has nvm || lkm_error "nvm install failed"

  # install latest long term support version
  nvm install --lts=Boron

  if [ $? -eq 0 ]; then
    # check which node and npm
    echo "checking which node"
    which node
    echo "checking which npm"
    which npm

    # check npm version
    echo "checking npm version"
    npm -v

    lkm_notify "After switching node versions, remember to run \`npm build\`."
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  CHECK FOR MISSING PROGRAMS

# loop through check list and add missing npms to install list
qc_npm_check() {
  local pkg
  local pkg_version

  for pkg in "${npm_check_list[@]}"
  do
    if npm ls -gs | grep -q "${pkg}@"; then
      pkg_version=$(npm ls -gs | grep "${pkg}@" | cut -d "@" -f 2)
      lkm_print_pkg_info "$pkg" "$pkg_version"
    else
      echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
      npm_install_list+=($pkg)
    fi
  done

  RET="$?"
  lkm_debug
}

# --------------------------  INSTALL MISSING PROGRAMS

# loop through install list and install any npms that are in the list
qc_npm_install() {
  # make sure npm is installed before proceeding
  lkm_has npm || { lkm_notify3 "warning: nodejs is not installed, skipping npms" && return 0; }

  npm build
  qc_npm_check

  if [[ "${#npm_install_list[@]}" -eq 0 ]]; then
    lkm_notify "No npms to install"
  else
    # install required npms
    lkm_pause "Press [Enter] to install npms" true
    if [ -d ~/.nvm ]; then
      # shellcheck disable=SC2068
      npm install -g ${npm_install_list[@]}
    else
      notify2 "missing ~/.nvm directory, skipping npm installs"
    fi
  fi

  # shellcheck disable=SC2034
  RET="$?"
  lkm_debug
}

echo
echo "NODE.JS"
echo
lkm_notify "Packages to install with npm"
read -rep "   : " -i 'bower browser-sync coffee-script csslint doctoc gulp npm-check-updates remark remark-lint' NPMS

# --------------------------  ARRAY ASSIGNMENTS

# add npms to check
npm_check_list+=($NPMS)

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the install script
qc_reset() {
  unset -f qc_reset qc_npm_install qc_npm_check qc_nvm
}

# --------------------------  INSTALL PROGRAMS

lkm_confirm "Install Nodejs via NVM?" true
if [ $? -eq 0 ]; then
  qc_nvm
fi
qc_npm_install
qc_reset

} # this ensures the entire script is downloaded #
