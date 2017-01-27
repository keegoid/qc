#!/bin/bash

{ # this ensures the entire script is downloaded #

echo "# --------------------------------------------"
echo "# Quickly configures a fresh install of       "
echo "# Ubuntu 16.04 64-bit.                        "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: keegoid.com                        "
echo "# Email  : keeganmullaney@gmail.com           "
echo "# License: keegoid.mit-license.org            "
echo "# --------------------------------------------"

# library file
# shellcheck disable=SC1091
source libkm.sh

# --------------------------  SETUP PARAMETERS

QC_APP_NAME="qc"
QC_DIR="$PWD"

# set to true (0) to prevent clearing the screen and report errors
QC_DEBUG_MODE=0

# make sure $HOME variable is set
lkm_variable_set "$HOME"

# config for server
lkm_confirm "Is this a server?"
QC_IS_SERVER="$?"

# make sure curl and git are installed
lkm_program_must_exist curl
lkm_program_must_exist git

# --------------------------  FUNCTIONS

# if any files in home are not owned by home user, fix that
qc_fix_permissions() {
  # set ownership
  lkm_pause "Press [Enter] to make sure all files in $HOME are owned by $(whoami)" true
  sudo chown --preserve-root -cR "$(whoami)":"$(whoami)" "$HOME"
}

# display message before exit
qc_exit_msg() {
  echo
  lkm_notify "Lastly: execute ./sudoers.sh to increase the sudo timeout."
  lkm_msg             "\nThanks for using $QC_APP_NAME."
  lkm_msg             "(c) $(date +%Y) keegoid.mit-license.org"
}

# --------------------------  MENU OPTIONS

qc_display_menu() {
  [ $QC_DEBUG_MODE -eq 1 ] || clear
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  if [ $QC_IS_SERVER -eq 0 ]; then
  echo "     M A I N - M E N U     "
  echo "          server           "
  else
  echo "     M A I N - M E N U     "
  echo "        workstation        "
  fi
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "1.  APT PACKAGES & UPDATES"
  echo "2.  RUBY & RUBYGEMS VIA RBENV"
  echo "3.  NODEJS & NPMS VIA NVM"
  echo "4.  PYTHON PACKAGES VIA PIP"
  echo "5.  SUBLIME TEXT"
  echo "6.  KEYBASE"
  echo "7.  SYSTEM CONFIG"
  echo "8.  SSH KEY"
  echo "9.  VIRTUALBOX & VAGRANT"
  echo "10. WORDPRESS WITH LXD, ZFS & JUJU"
  echo "11. FIX PERMISSIONS"
  echo "12. QUIT"
}

# --------------------------  USER SELECTION

qc_select_options() {
  local choice
  # make sure we're always starting from the right place
  cd "$QC_DIR" || exit
  read -rp "Enter choice [1 - 12]: " choice
  case $choice in
    1)  lkm_run_script apts.sh "script";;
    2)  lkm_run_script gems.sh "script";;
    3)  lkm_run_script npms.sh "script";;
    4)  lkm_run_script pips.sh "script";;
    5)  lkm_run_script subl.sh "script";;
    6)  lkm_run_script keybase.sh "script";;
    7)  lkm_run_script config.sh "script";;
    8)  lkm_run_script sshkey.sh "script";;
    9)  lkm_run_script vm.sh "script";;
    10) lkm_run_script lxd.sh "script";;
    11) qc_fix_permissions;;
    12) qc_exit_msg && exit 0;;
    *)  lkm_alert "Error..." && sleep 1
  esac

  # check for program errors
  # shellcheck disable=SC2034
  RET="$?"
  lkm_debug
}

# trap Ctrl+Z to return to the main menu
trap "echo; qc_menu_loop" SIGTSTP

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the script
qc_reset() {
  unset -f qc_reset qc_menu_loop qc_display_menu qc_select_options qc_exit_msg qc_fix_permissions
}

# --------------------------  MAIN

qc_menu_loop() {
  # infinite loop until user exits
  while true; do
    qc_display_menu
    qc_select_options
    lkm_pause
  done
}
# start program
qc_menu_loop
qc_reset

} # this ensures the entire script is downloaded #
