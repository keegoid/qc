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

source vars.sh

# source function libraries
for lib in $LIBS; do
   [ -d "$LIBS_DIR" ] && { source "$LIBS_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIBS_DIR/$lib" || echo "can't find: $LIBS_DIR/$lib"; }
done

# make sure curl is installed
[ -z "$(apt-cache policy curl | grep '(none)')" ] || { echo >&2 "curl will be installed."; sudo apt-get -y install curl; }

pause

# local repository location
#echo
#REPOS=$(locate_repos $USER_NAME $DROPBOX)
#echo "repository location: $REPOS"

# install software and update system
function updates_go()
{
   echo "# -------------------------------"
   echo "# SECTION 1: INSTALLS & UPDATES  "
   echo "# -------------------------------"

   # install and update software
   run_script linux_update.sh
   pause
}
 
# git
function git_go()
{
   echo "# -------------------------------"
   echo "# SECTION 2: GIT CONFIG          "
   echo "# -------------------------------"

   # setup git
   run_script git_config.sh
   pause
}

# ssh
function ssh_go()
{
   echo "# -------------------------------"
   echo "# SECTION 3: SSH KEY             "
   echo "# -------------------------------"

   # setup git
   run_script ssh_key.sh
   pause
}

# aliases
function aliases_go()
{
   echo "# -------------------------------"
   echo "# SECTION 4: ALIASES             "
   echo "# -------------------------------"

   # add useful aliases
   run_script aliases.sh
   pause
}

# config
function terminal_go()
{
   echo "# -------------------------------"
   echo "# SECTION 5: TERMINAL CONFIG     "
   echo "# -------------------------------"

   # setup the terminal
   run_script terminal_config.sh
   pause
}

# code to run before exit
function finish_up()
{
   # set ownership
   sudo chown -cR $USER_NAME:$USER_NAME "$WORKING_DIR"
   echo
   echo "# --------------------------------------------------------------------"
   echo "# Lastly: execute sudo ./sudoers.sh to increase the sudo timeout.     "
   echo "# --------------------------------------------------------------------"
   echo
   echo "Thanks for using this ubuntu-quick-config script."
   echo
}

# display the menu
display_menu()
{
   clear
   echo "~~~~~~~~~~~~~~~~~~~~~~~"	
   echo "   M A I N - M E N U   "
   echo "~~~~~~~~~~~~~~~~~~~~~~~"
   echo "1. INSTALLS & UPDATES"
   echo "2. GIT CONFIG"
   echo "3. SSH KEY"
   echo "4. ALIASES"
   echo "5. TERMINAL CONFIG"
   echo "6. EXIT"
}

# user selection
select_options()
{
   local choice
   read -p "Enter choice [1 - 6]: " choice
   case $choice in
      1) updates_go;;
      2) git_go;;
      3) ssh_go;;
      4) aliases_go;;
      5) terminal_go;;
      6) finish_up && exit 0;;
      *) echo -e "${RED}Error...${STD}" && sleep 2
   esac
}
 
# ----------------------------------------------
# trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
#trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# main loop (infinite)
# ------------------------------------
while true; do
   display_menu
   select_options
done

