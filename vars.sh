#!/bin/bash
echo "# --------------------------------------------"
echo "# Set global variables for run.sh script.     "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Company: KM Authorized LLC                  "
echo "# Website: http://kmauthorized.com            "
echo "#                                             "
echo "# MIT: http://kma.mit-license.org             "
echo "# --------------------------------------------"

# --------------------------------------------------
# EDIT THESE VARIABLES WITH YOUR INFO
USER_NAME='kmullaney' # your Linux user
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='coding key'
GITHUB_USER='keegoid' # your GitHub username
GIT_EDITOR='nano'
PROXY_ADDRESS='127.0.0.1:8787' # default uses Lantern, make sure it is installed first

# programs to install
WORKSTATION_PROGRAMS='deluge git gnupg2 gufw lynx nautilus-open-terminal npm pip python-gpgme xclip vagrant virtualbox virtualbox-guest-additions-iso vlc'

# gems to install
GEM_PROGRAMS='gist'

# pips to install
PIP_PROGRAMS='jrnl[encrypted]'

# npms to install
NPM_PROGRAMS='doctoc keybase-installer'

# what to allow from the Internet
SERVICES=''
TCP_PORTS=''
UDP_PORTS=''

# whitelisted IPs
TRUSTED_IPV4_HOSTS=""

TRUSTED_IPV6_HOSTS=""
# --------------------------------------------------

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

