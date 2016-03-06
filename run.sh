#!/bin/bash
echo "# --------------------------------------------"
echo "# Quickly configures a fresh install of       "
echo "# Ubuntu 14.04 64-bit.                        "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

APP_NAME="ubuntu-quick-config"
PROJECT="$PWD"

# set to true (0) to prevent clearing the screen and report errors
DEBUG_MODE=1

# library file
source includes/libkm.sh

# make sure $HOME variable is set
variable_set $HOME

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
   pause "Press [Enter] to make sure all files in $HOME are owned by $(logname)" true
   sudo chown --preserve-root -cR $(logname):$(logname) $HOME
}

# display message before exit
exit_msg() {
   echo
   notify "Lastly: execute sudo ./sudoers.sh to increase the sudo timeout."
   msg             "\nThanks for using $APP_NAME."
   msg             "© `date +%Y` http://keegoid.mit-license.org"
}

# --------------------------  MENU OPTIONS

display_menu() {
      [ $DEBUG_MODE -eq 0 ] || clear
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
   if [ $IS_SERVER -eq 0 ]; then
      echo "     M A I N - M E N U     "
      echo "          server           "
   else
      echo "     M A I N - M E N U     "
      echo "        workstation        "
   fi
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      echo "1. INSTALLS & UPDATES"
      echo "2. SYSTEM CONFIG"
      echo "3. SSH KEY"
      echo "4. WORDPRESS DEVELOPMENT"
      echo "5. FIX PERMISSIONS"
      echo "6. QUIT"
}

# --------------------------  USER SELECTION

select_options() {
   local choice
   # make sure we're always starting from the right place
   cd "$PROJECT"
   read -rp "Enter choice [1 - 6]: " choice
   case $choice in
      1) run_script linux_update.sh "scripts";;
      2) run_script system_config.sh "scripts";;
      3) run_script ssh_key.sh "scripts";;
      4) run_script wordpress_flockport.sh "scripts";;
      5) fix_permissions;;
      6) exit_msg && exit 0;;
      *) alert "Error..." && sleep 1
   esac

   # check for program errors
   RET=$?
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

