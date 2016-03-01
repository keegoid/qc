#!/bin/bash
echo "# --------------------------------------------"
echo "# Quickly configures a fresh install of       "
echo "# Ubuntu 14.04 x64.                           "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# set to true (0) prevent clearing the screen
DEBUG=1

# library files
LIBS='base.sh software.sh git.sh'
LIBS_DIR='includes'

# source function libraries
for lib in $LIBS; do
   [ -d "$LIBS_DIR" ] && { source "$LIBS_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIBS_DIR/$lib" || echo "can't find: $LIBS_DIR/$lib"; }
done

# project directory
PROJECT="$PWD"

# config for server
confirm "Is this a server?"
IS_SERVER=$?

# make sure curl and git are installed
install_apt "curl git"

# if any files in home are not owned by home user, fix that
fix_permissions() {
   # set ownership
   pause "Press [Enter] to make sure all files in $HOME are owned by $(logname)" true
   sudo chown --preserve-root -cR $(logname):$(logname) "$HOME"
}

# display message before exit
exit_msg() {
   echo
   echo -e "${LIGHT_GRAY} Lastly: execute sudo ./sudoers.sh to increase the sudo timeout. ${STD}"
   echo
   echo "Thanks for using this ubuntu-quick-config script."
}

# --------------------------------------------
# display the menu
# --------------------------------------------
display_menu()

      [ $DEBUG -eq 0 ] || clear
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
      echo "2. GIT CONFIG"
      echo "3. SSH KEY"
      echo "4. TERMINAL CONFIG"
      echo "5. WORDPRESS DEVELOPMENT"
      echo "6. FIX PERMISSIONS"
      echo "7. QUIT"
}

# --------------------------------------------
# user selection
# --------------------------------------------
select_options()
{
   local choice
   # make sure we're always starting from the right place
   cd "$PROJECT"
   read -rp "Enter choice [1 - 7]: " choice
   case $choice in
      1) run_script linux_update.sh    $DEBUG;;
      2) run_script git_config.sh      $DEBUG;;
      3) run_script ssh_key.sh         $DEBUG;;
      4) run_script terminal_config.sh $DEBUG;;
      5) run_script wordpress_dev.sh   $DEBUG;;
      6) fix_permissions;;
      7) exit_msg && exit 0;;
      *) echo -e "${RED} Error... ${STD}" && sleep 1
   esac
}

# --------------------------------------------
# trap Ctrl+Z to return to the main menu
# --------------------------------------------
trap "echo; menu_loop" SIGTSTP

# --------------------------------------------
# main loop (infinite)
# --------------------------------------------
menu_loop()
{
   while true; do
      display_menu
      select_options
      pause
   done
}
# call menu loop before program end
menu_loop

