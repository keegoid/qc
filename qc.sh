#!/bin/bash

{ # this ensures the entire script is downloaded #

echo "# --------------------------------------------"
echo "# Quickly configures a fresh install of       "
echo "# Ubuntu Desktop 19.10.                       "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: keegoid.com                        "
echo "# Email  : keegan@kmauthorized.com            "
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

# make sure curl and git are installed
lkm_program_must_exist curl
lkm_program_must_exist git

# --------------------------  FUNCTIONS

# if any files in home are not owned by home user, fix that
qc_fix_permissions() {
  # set ownership
  lkm_notify2 "Warning: The following is a dangerous command, run at your own risk."
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
  echo "     M A I N - M E N U     "
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo "1.  APT PACKAGES & UPDATES"
  echo "2.  RUBY & RUBYGEMS VIA RBENV"
  echo "3.  NODEJS & NPMS VIA NVM"
  echo "4.  PYTHON & PIP VIA VIRTUALENV"
  echo "5.  SUBLIME TEXT 3"
  echo "6.  KEYBASE"
  echo "7.  SYSTEM CONFIG"
  echo "8.  SSH KEY"
  echo "9.  FIX HOME OWNERSHIP"
  echo "10. QUIT"
}

# --------------------------  USER SELECTION

qc_select_options() {
  local choice
  # make sure we're always starting from the right place
  cd "$QC_DIR" || exit
  read -rp "Enter choice [1 - 10]: " choice
  case $choice in
    1) lkm_run_script apts.sh "script";;
    2) lkm_run_script gems.sh "script";;
    3) lkm_run_script npms.sh "script";;
    4) lkm_run_script pips.sh "script";;
    5) lkm_run_script subl.sh "script";;
    6) lkm_run_script keybase.sh "script";;
    7) lkm_run_script config.sh "script";;
    8) lkm_run_script sshkey.sh "script";;
    9) qc_fix_permissions;;
    10) qc_exit_msg && exit 0;;
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
