#!/bin/bash
# --------------------------------------------
# Set global variables for run.sh script.
#
# Author : Keegan Mullaney
# Website: http://keegoid.com
# Email  : keeganmullaney@gmail.com
#
# http://keegoid.mit-license.org
# --------------------------------------------

# --------------------------------------------
# EDIT THESE VARIABLES WITH YOUR INFO
USER_NAME='kmullaney' # your Linux user
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='coding key'
GITHUB_USER='keegoid' # your GitHub username
GIT_EDITOR='vi'
#PROXY_ADDRESS='http://127.0.0.1:8787' # default uses Lantern
# programs to be installed
WORKSTATION_PROGRAMS='deluge gist git gnupg2 gufw lynx nautilus-open-terminal xclip vagrant vim virtualbox virtualbox-guest-additions-iso vlc'
SERVER_PROGRAMS='openssh-server'
#GEM_PROGRAMS='gist'
PIP_PROGRAMS='jrnl[encrypted]'
NPM_PROGRAMS='doctoc'
# --------------------------------------------

# for screen error messages
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# library files
LIBS='base.lib software.lib git.lib'
LIBS_DIR='includes'

# save current directory
WORKING_DIR="$PWD"

# config for server
IS_SERVER=false
echo
echo "Is this a server?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") IS_SERVER=true;;
       "No") break;;
          *) echo "case not found, try again..."
             continue;;
   esac
   break
done

# use Dropbox for Repos directory?
#DROPBOX=false
#echo
#echo "Are you using Dropbox for your repositories?"
#select yn in "Yes" "No"; do
#   case $yn in
#      "Yes") DROPBOX=true;;
#       "No") break;;
#          *) echo "case not found..."
#             continue;;
#   esac
#   break
#done

