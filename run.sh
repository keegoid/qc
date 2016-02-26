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

# set to true prevent clearing the screen
DEBUG=false

# project directory
PROJECT_DIRECTORY="$PWD"

# library files
LIBS='base.sh software.sh git.sh'
LIBS_DIR='includes'

# for screen error messages
LIGHT_GRAY='\033[0;47;30m'
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# source function libraries
for lib in $LIBS; do
   [ -d "$LIBS_DIR" ] && { source "$LIBS_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIBS_DIR/$lib" || echo "can't find: $LIBS_DIR/$lib"; }
done

# config for server
IS_SERVER=$(confirm "Is this a server?")
echo "please wait..."
# make sure curl and git are installed
install_apt "curl git"
#install_apt "curl git openssh-server"

# user inputs
read -ep "enter your name for git: " -i 'Keegan Mullaney' REAL_NAME
read -ep "enter your email for git: " -i 'keeganmullaney@gmail.com' EMAIL_ADDRESS
read -ep "enter your prefered text editor for git: " -i 'vi' GIT_EDITOR
read -ep "enter a comment for your ssh key: " -i 'coding key' SSH_KEY_COMMENT
read -ep "enter directory to use for repositories or code projects: " -i "$HOME/Dropbox/Repos" REPOS_DIRECTORY
read -ep "enter apps to install with apt-get: " -i 'deluge gist gnupg2 gufw lynx mutt nautilus-open-terminal x11vnc xclip vim vlc' APT_PROGRAMS
read -ep "enter apps to install with pip: " -i 'jrnl[encrypted]' PIP_PROGRAMS
read -ep "enter apps to install with npm: " -i 'doctoc' NPM_PROGRAMS

# code to run before exit
function finish_up()
{
   # set ownership
   pause "Press [Enter] to make sure all files in $HOME are owned by $(logname)" true
   sudo chown -cR $(logname):$(logname) "$HOME"
   echo
   echo -e "${LIGHT_GRAY} Lastly: execute sudo ./sudoers.sh to increase the sudo timeout. ${STD}"
   echo
   echo "Thanks for using this ubuntu-quick-config script."
}

# --------------------------------------------
# display the menu
# --------------------------------------------
function display_menu()
{
      [ "$DEBUG" = true ] || clear
      echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~"	
   if [ "$IS_SERVER" = true ]; then
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
      echo "4. ALIASES"
      echo "5. TERMINAL CONFIG"
      echo "6. WORDPRESS DEVELOPMENT"
      echo "7. EXIT"
}

# --------------------------------------------
# user selection
# --------------------------------------------
function select_options()
{
   local choice
   # make sure we're always starting from the right place
   cd "$PROJECT_DIRECTORY"
   read -rp "Enter choice [1 - 7]: " choice
   case $choice in
      1) run_script linux_update.sh    $DEBUG;;
      2) run_script git_config.sh      $DEBUG;;
      3) run_script ssh_key.sh         $DEBUG;;
      4) run_script aliases.sh         $DEBUG;;
      5) run_script terminal_config.sh $DEBUG;;
      6) run_script wordpress_dev.sh   $DEBUG;;
      7) finish_up && exit 0;;
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
function menu_loop()
{
   while true; do
      display_menu
      select_options
      pause
   done
}
# call menu loop before program end
menu_loop

