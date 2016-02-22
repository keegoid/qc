#!/bin/bash
echo "# --------------------------------------------"
echo "# Quickly configures a fresh install of       "
echo "# Ubuntu 14.04 x64 for a workstation.         "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

source vars.sh

# check to make sure script is being run as root
is_root && echo "root user detected, proceeding..." || die "\033[40m\033[1;31mERROR: root check FAILED (you must be root to use this script). Quitting...\033[0m\n"

# source function libraries
for lib in $LIBS; do
   [ -d "$LIB_DIR" ] && { source "$LIB_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIB_DIR/$lib" || echo "can't find: $LIB_DIR/$lib"; }
done

# make sure curl is installed
hash curl 2>/dev/null || { echo >&2 "curl will be installed."; apt-get -y install curl; }

# create Linux non-root user
echo
pause "Press enter to create user \"$USER_NAME\" if it doesn't exist..."
/usr/sbin/adduser $USER_NAME

# check if user exists
if ! user_exists $USER_NAME; then
   die "\033[40m\033[1;31mERROR: $USER_NAME does not exist. Quitting...\033[0m\nQuitting..."
fi

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
      6) exit 0;;
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

# set ownership
echo
#chown -cR $USER_NAME:$USER_NAME "$REPOS"
chown -cR $USER_NAME:$USER_NAME "$WORKING_DIR"

echo
echo "# --------------------------------------------------------------------"
echo "# Execute sudo ./sudoers.sh to increase the sudo timeout.             "
echo "# --------------------------------------------------------------------"

echo
echo "Thanks for using the ubuntu-workstation-setup script."

