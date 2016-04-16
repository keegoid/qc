#!/bin/bash
echo "# --------------------------------------------"
echo "# Quickly configures a fresh install of       "
echo "# Ubuntu 16.04 64-bit.                        "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# library file
source libkm.sh

# --------------------------  SETUP PARAMETERS

APP_NAME="quick-config"
PROJECT="$PWD"

# set to true (0) to prevent clearing the screen and report errors
DEBUG_MODE=0

# make sure $HOME variable is set
variable_set "$HOME"

# config for server
confirm "Is this a server?"
IS_SERVER="$?"

# make sure curl and git are installed
program_must_exist curl
program_must_exist git

# --------------------------  FUNCTIONS

# if any files in home are not owned by home user, fix that
fix_permissions() {
    # set ownership
    pause "Press [Enter] to make sure all files in $HOME are owned by $(whoami)" true
    sudo chown --preserve-root -cR "$(whoami)":"$(whoami)" "$HOME"
}

# display message before exit
exit_msg() {
    echo
    notify "Lastly: execute sudo ./sudoers.sh to increase the sudo timeout."
    msg             "\nThanks for using $APP_NAME."
    msg             "(c) $(date +%Y) http://keegoid.mit-license.org"
}

# --------------------------  MENU OPTIONS

display_menu() {
      [ "$DEBUG_MODE" -eq 1 ] || clear
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    if [ "$IS_SERVER" -eq 0 ]; then
      echo "     M A I N - M E N U     "
      echo "          server           "
    else
      echo "     M A I N - M E N U     "
      echo "        workstation        "
    fi
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "1. UBUNTU PACKAGES & UPDATES"
      echo "2. SUBLIME TEXT"
      echo "3. KEYBASE"
      echo "4. SYSTEM CONFIG"
      echo "5. SSH KEY"
      echo "6. VIRTUALBOX & VAGRANT"
      echo "7. WORDPRESS WITH LXD, ZFS & JUJU"
      echo "8. FIX PERMISSIONS"
      echo "9. QUIT"
}

# --------------------------  USER SELECTION

select_options() {
    local choice
    # make sure we're always starting from the right place
    cd "$PROJECT"
    read -rp "Enter choice [1 - 9]: " choice
    case $choice in
        1) run_script installs.sh "scripts";;
        2) run_script subl.sh "scripts";;
        3) run_script keybase.sh "scripts";;
        4) run_script config.sh "scripts";;
        5) run_script sshkey.sh "scripts";;
        6) run_script vm.sh "scripts";;
        7) run_script lxd.sh "scripts";;
        8) fix_permissions;;
        9) exit_msg && exit 0;;
        *) alert "Error..." && sleep 1
    esac

    # check for program errors
    # shellcheck disable=SC2034
    RET="$?"
    debug
}

# trap Ctrl+Z to return to the main menu
trap "echo; menu_loop" SIGTSTP

# --------------------------  MAIN

menu_loop() {
    # infinite loop until user exits
    while true; do
        display_menu
        select_options
        pause
    done
}
# start program
menu_loop
