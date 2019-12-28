#!/bin/bash
# --------------------------------------------
# Install / update PIPs via Virtualenv
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keegan@kmauthorized.com
# License: keegoid.mit-license.org
#
# Attributions:
# package install functions & lists
# github.com/Varying-Vagrant-Vagrants/VVV/
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  MISSING PROGRAM CHECKS

# install lists (perform install)
pip_install_list=()
pip3_install_list=()

# check lists (check if installed)
pip_check_list=()
pip3_check_list=()

# --------------------------  CUSTOM INSTALL SCRIPTS

# install the Virtualenv to manage Python versions
qc_virtualenv() {
  # make sure dependencies are installed
  sudo apt update
  lkm_program_must_exist "python-pip"
  lkm_program_must_exist "python-setuptools"

  # install Virtualenv
  sudo -H pip install virtualenv

  # install PIP, wheel and Python
  virtualenv ~/.virtualenv

  # source virtualenv
  # shellcheck disable=SC2016
  lkm_set_source_cmd      "$HOME/.bashrc" \
                          'virtualenv/bin:' \
                          '[[ ":$PATH:" =~ ":$HOME/.virtualenv/bin:" ]] || PATH="$HOME/.virtualenv/bin:$PATH"'
  # shellcheck source=/dev/null
  source ~/.bashrc

  # check which pip
  command -v pip

  # check versions
  virtualenv --version
  pip -V

  RET="$?"
  lkm_debug
}

# --------------------------  CHECK FOR MISSING PROGRAMS

# loop through check list and add missing pips to install list
qc_pip_check() {
  local pkg
  local pkg_trim
  local pkg_version

  for pkg in "${pip_check_list[@]}"
  do
    pkg_trim=$(lkm_trim_longest_right_pattern "$pkg" "[")
    if pip list | grep -w "$pkg_trim" >/dev/null 2>&1; then
      pkg_version=$(pip list | grep -w "${pkg_trim}" | cut -d " " -f 2 | tr -d "(" | tr -d ")")
      lkm_print_pkg_info "$pkg" "$pkg_version"
    else
      echo -e " ${YELLOW_BLACK} * $pkg_trim [not installed] ${NONE_WHITE}"
      pip_install_list+=($pkg)
    fi
  done

  RET="$?"
  lkm_debug
}

# loop through check list and add missing pip3s to install list
qc_pip3_check() {
  local pkg
  local pkg_trim
  local pkg_version

  for pkg in "${pip3_check_list[@]}"
  do
    pkg_trim=$(lkm_trim_longest_right_pattern "$pkg" "[")
    if pip list | grep -w "$pkg_trim" >/dev/null 2>&1; then
      pkg_version=$(pip3 list | grep -w "${pkg_trim}" | cut -d " " -f 2 | tr -d "(" | tr -d ")")
      lkm_print_pkg_info "$pkg" "$pkg_version"
    else
      echo -e " ${YELLOW_BLACK} * $pkg_trim [not installed] ${NONE_WHITE}"
      pip3_install_list+=($pkg)
    fi
  done

  RET="$?"
  lkm_debug
}

# --------------------------  INSTALL MISSING PROGRAMS

# loop through install list and install any pips that are in the list
qc_pip_install() {
  # make sure dependencies are installed
  lkm_program_must_exist "python-pip"
  lkm_program_must_exist "python-setuptools"
  lkm_program_must_exist "python-keyring"

  qc_pip_check

  if [[ "${#pip_install_list[@]}" -eq 0 ]]; then
    lkm_notify "No pips to install"
  else
    # install required pips
    lkm_pause "Press [Enter] to install pips" true
    # shellcheck disable=SC2068
    pip install ${pip_install_list[@]}
  fi

  RET="$?"
  lkm_debug
}

# loop through install list and install any pips that are in the list
qc_pip3_install() {
  # make sure dependencies are installed
  lkm_program_must_exist "python3-pip"

  qc_pip3_check

  if [[ "${#pip3_install_list[@]}" -eq 0 ]]; then
    lkm_notify "No pip3s to install"
  else
    # install required pips
    lkm_pause "Press [Enter] to install pip3s" true
    # shellcheck disable=SC2068
    pip3 install ${pip3_install_list[@]}
  fi

  # shellcheck disable=SC2034
  RET="$?"
  lkm_debug
}

echo
echo "PIPs"
echo
lkm_notify "Packages to install with pip"
read -rep "   : " -i 'jrnl[encrypted] pyflakes python-slugify keyrings.alt' PIPS
lkm_notify "Packages to install with pip3"
# shellcheck disable=SC2034
read -rep "   : " -i 'pep8' PIP3S

# --------------------------  ARRAY ASSIGNMENTS

# add pips to check
pip_check_list+=($PIPS)
pip3_check_list+=($PIP3S)

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the install script
qc_reset() {
  unset -f qc_reset qc_pip_install qc_pip_check qc_virtualenv
}

# --------------------------  INSTALL PROGRAMS

lkm_confirm "Install PIP via Virtualenv?" true
# check if virtualenv and pip are already installed
qc_virtualenv
echo "Close the terminal window and reopen to enable the new PIP with Virtualenv."
qc_pip_install
qc_pip3_install

qc_reset

} # this ensures the entire script is downloaded #
