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

# library files
LIBS='base.sh software.sh git.sh'
LIBS_DIR='includes'

# for screen error messages
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# source function libraries
for lib in $LIBS; do
   [ -d "$LIBS_DIR" ] && { source "$LIBS_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIBS_DIR/$lib" || echo "can't find: $LIBS_DIR/$lib"; }
done

# config for server
IS_SERVER=$(confirm "Is this a server?")

# user inputs
read -ep "enter your name for git: " -i 'Keegan Mullaney' REAL_NAME
read -ep "enter your email for git: " -i 'keeganmullaney@gmail.com' EMAIL_ADDRESS
read -ep "enter your prefered text editor for git: " -i 'vi' GIT_EDITOR
read -ep "enter a comment for your ssh key: " -i 'coding key' SSH_KEY_COMMENT
read -ep "enter directory to use for repositories or code projects" -i "$HOME/Dropbox/Repos" REPOS_DIRECTORY
read -ep "enter apps to install with apt-get: " -i 'deluge gist gnupg2 gufw lynx nautilus-open-terminal xclip vim vlc' APT_PROGRAMS
read -ep "enter apps to install with pip: " -i 'jrnl[encrypted]' PIP_PROGRAMS
read -ep "enter apps to install with npm: " -i 'doctoc' NPM_PROGRAMS

# make sure curl and git are installed
install_apt "curl git"
#install_apt "curl git openssh-server"

# local repository location
# use Dropbox for Repos directory?
#DROPBOX=confirm "Are you using Dropbox for your repositories?"
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

# wordpress
function wordpress_go()
{
   echo "# -------------------------------"
   echo "# SECTION 6: WORDPRESS DEV       "
   echo "# -------------------------------"

   # install requirements for WordPress development
   run_script wordpress_dev.sh
   pause
}

# code to run before exit
function finish_up()
{
   # set ownership
   sudo chown -cR $(logname):$(logname) "$HOME"
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
   if [ "$IS_SERVER" = true ]; then
      echo "   M A I N - M E N U   "
      echo "        server         "
   else
      echo "   M A I N - M E N U   "
      echo "      workstation      "
   fi
   echo "~~~~~~~~~~~~~~~~~~~~~~~"
   echo "1. INSTALLS & UPDATES"
   echo "2. GIT CONFIG"
   echo "3. SSH KEY"
   echo "4. ALIASES"
   echo "5. TERMINAL CONFIG"
   echo "6. WORDPRESS DEVELOPMENT"
   echo "7. EXIT"
}

# user selection
select_options()
{
   local choice
   read -rp "Enter choice [1 - 7]: " choice
   case $choice in
      1) updates_go;;
      2) git_go;;
      3) ssh_go;;
      4) aliases_go;;
      5) terminal_go;;
      6) wordpress_go;;
      7) finish_up && exit 0;;
      *) echo -e "${RED}Error...${STD}" && sleep 1
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

