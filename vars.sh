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
PROXY_ADDRESS='127.0.0.1:8787' # default uses Lantern, make sure it is installed first
APT_PROGRAMS='deluge git gnupg2 gufw lynx nautilus-open-terminal npm pip python-gpgme xclip vagrant virtualbox virtualbox-guest-additions-iso vlc' # apts to install
GEM_PROGRAMS='gist' # gems to install
PIP_PROGRAMS='jrnl[encrypted]' # pips to install
NPM_PROGRAMS='doctoc keybase-installer' # npms to install
# --------------------------------------------

# for screen error messages
RED='\033[0;41;30m'
STD='\033[0;0;39m'

# library files
LIBS='base.lib software.lib git.lib'
LIBS_DIR='includes'

# save current directory
WORKING_DIR="$PWD"

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

