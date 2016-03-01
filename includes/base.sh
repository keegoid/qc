#!/bin/bash
# --------------------------------------------
# A library of useful Linux functions
#
# Author : Keegan Mullaney
# Website: http://keegoid.com
# Email  : keeganmullaney@gmail.com
#
# http://keegoid.mit-license.org
# --------------------------------------------

# note: true=0 and false=1 in bash

# for screen error messages
declare -r LIGHT_GRAY='\033[0;47;30m'
declare -r RED='\033[0;41;30m'
declare -r STD='\033[0;0;39m'

# purpose: converts a string to lower case
# arguments:
#   $1 -> string to convert to lower case
to_lower() {
    local str="$@"
    local output     
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    echo $output
}


# purpose: trim shortest pattern from the left
# arguments:
#   $1 -> variable
#   $2 -> pattern
trim_shortest_left_pattern() {
   echo -n "${1#*$2}"
   # -n (don't create newline character)
}

# purpose: trim longest pattern from the left
# arguments:
#   $1 -> variable
#   $2 -> pattern
trim_longest_left_pattern() {
   echo -n "${1##*$2}"
}

# purpose: trim shortest pattern from the right
# arguments:
#   $1 -> variable
#   $2 -> pattern
trim_shortest_right_pattern() {
   echo -n "${1%$2*}"
}

# purpose: trim longest pattern from the right
# arguments:
#   $1 -> variable
#   $2 -> pattern
trim_longest_right_pattern() {
   echo -n "${1%%$2*}"
}

# purpose: to display an error message and die
# arguments:
#   $1 -> message
#   $2 -> exit status (optional)
die() {
    local m=$1 	   # message
    local e=${2-1}	# default exit status 1
    printf "$m"
    exit $e
}

# purpose: wait for user to press enter
# arguments:
#   $1 -> user message
#   #2 -> use back option?
pause() {
   local msg="$1"
   local back="$2"
   # default message
   [ -z "${msg}" ] && msg="Press [Enter] key to continue"
   # how to go back, with either default or user message
   [ "$back" = true ] && msg="${msg}, [Ctrl+Z] to go back" 
   read -p "$msg..."
}

# purpose: return true if script is executed by the root user
# arguments: none
# return: true or die with message
is_root() {
#   [ $(id -u) -eq 0 ] && return 0 || return 1
   [ "$EUID" -eq 0 ] && return 0 || return 1
}
 
# purpose: return true if $user exits in /etc/passwd
# arguments:
#   $1 -> username to check in /etc/passwd
# return: true or false
user_exists() {
   local u="$1"
   # -q (quiet), -w (only match whole words, otherwise "user" would match "user1" and "user2")
   if grep -qw "^${u}" /etc/passwd; then
      #echo "user $u exists in /etc/passwd"
      return 0
   else
      #echo "user $u does not exists in /etc/passwd"
      return 1
   fi
}

# purpose: prompt user with binary option
# arguments:
#   $1 -> text string to prompt user
#   #2 -> default to no? (optional)
# return: true or false
confirm() {
   local text="$1"
   local preferNo="$2"

   # check preference
   if [ -n "${preferNo}" ] && [ "${preferNo}" = false ]; then
      # prompt user with preference for Yes
      read -rp "${text} [Y/n] " response
      case $response in
         [nN][oO]|[nN])
            return 1
            ;;
         *)
            return 0
            ;;
      esac
   else
      # prompt user with preference for No
      read -rp "${text} [y/N] " response
      case $response in
         [yY][eE][sS]|[yY]) 
            return 0
            ;;
         *) 
            return 1
            ;;
      esac
   fi
}

# purpose: return name of script being run
# arguments:
#   $1 -> message before
#   $2 -> message after
script_name() {
#   echo "$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

   # can be accomplished with trim_longest_left_pattern instead
   echo -n "$1" && trim_longest_left_pattern $0 / && echo "$2"
}

# purpose: run a script from another script
# arguments:
#   $1 -> name of script to be run
#   #2 -> debug mode? (optional)
run_script() {
   local name="$1"

   # make sure dos2unix is installed
   not_installed dos2unix && sudo apt-get -y install dos2unix

   # change to scripts directory to run scripts
   cd scripts

   # get script ready to run
   dos2unix -k -q "${name}"
   chmod +x "${name}"

   # clear the screen and run the script
   [ "${2}" = true ] || clear
   . ./"${name}"
   echo "script: ${name} has finished"

   # change back to original directory
   cd - >/dev/null
}

# purpose: generate an RSA SSH keypair if none exists or copy from root
# arguments:
#   $1 -> SSH directory
#   $2 -> non-root Linux username
gen_ssh_keys() {
   local ssh_dir="$1"
   local u="$2"

   echo
   echo "Note: ${ssh_dir} is for public/private key pairs to establish SSH connections to remote systems"
   echo
   # check if id_rsa exists
   if [ -f "${ssh_dir}/id_rsa" ]; then
      echo "${ssh_dir}/id_rsa already exists"
   else
      # create a new ssh key with provided ssh key comment
      pause "Press [Enter] to generate a new SSH key at: ${ssh_dir}/id_rsa" true
      read -ep "Enter an ssh key comment: " -i 'coding key' comment
      ssh-keygen -b 4096 -t rsa -C "$comment"
      echo "SSH key generated"
      chmod -c 0600 "${ssh_dir}/id_rsa"
      chown -cR "${u}":"${u}" "${ssh_dir}"
      echo
      echo "*** NOTE ***"
      echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
      echo "of your GitHub account or authorized_keys section of your remote server."
      echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
      echo
      cat "${ssh_dir}/id_rsa.pub"
      echo
      read -p "Press [Enter] to continue..."
   fi
   echo
   echo "Have you copied id_rsa.pub (above) to the SSH keys section"
   echo "of your GitHub account?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") break;;
          "No") echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
                echo "of your GitHub account."
                echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
                echo
                cat "${ssh_dir}/id_rsa.pub";;
             *) echo "case not found, try again..."
                continue;;
      esac
      break
   done
}

# purpose: set authorized SSH keys for incoming connections on remote host
# arguments:
#   $1 -> SSH directory
#   $2 -> non-root Linux username
authorized_ssh_keys() {
   local ssh_dir="$1"
   local u="$2"
   local ssh_rsa

   echo
   echo "Note: ${ssh_dir}/authorized_keys are public keys to establish"
   echo "incoming SSH connections to a server"
   echo
   if [ -f "${ssh_dir}/authorized_keys" ]; then
      echo "${ssh_dir}/authorized_keys already exists for ${u}"
   else
#      passwd "${u}"
#      echo
#      echo "for su root command:"
#      passwd root # for su root command
      mkdir -pv "${ssh_dir}"
      chmod -c 0700 "${ssh_dir}"
      echo
      echo "*** NOTE ***"
      echo "Paste (using ctrl+shift+v) your public ssh-rsa key from your workstation"
      echo "to SSH into this server."
      read -ep "Paste it here: " ssh_rsa
      echo "${ssh_rsa}" > "${ssh_dir}/authorized_keys"
      echo "public SSH key saved to ${ssh_dir}/authorized_keys"
      chmod -c 0600 "${ssh_dir}/authorized_keys"
      chown -cR "${u}":"${u}" "${ssh_dir}"
   fi
}

# purpose: import public GPG key if it doesn't already exist in list of RPM keys
#          although rpm --import won't import duplicate keys, this is a proof of concept
# arguments:
#   $1 -> URL of the public key file
# return: false if URL is empty, else true
get_public_key() {
   local url="$1"
   local apt_keys="$HOME/apt_keys"

   [ -z "${url}" ] && echo false && return 1
   pause "Press [Enter] to download and import the GPG Key..."
   mkdir -pv "$apt_keys"
   cd "$apt_keys"
#   echo "changing directory to $_"
   # download keyfile
   wget -nc "$url"
   local key_file=$(trim_longest_left_pattern "${url}" /)
   # get key id
   local key_id=$(echo $(gpg --throw-keyids < "$key_file") | cut --characters=11-18 | tr [A-Z] [a-z])
   # import key if it doesn't exist
   if ! apt-key list | grep "$key_id" > /dev/null 2>&1; then
      echo "Installing GPG public key with ID $key_id from $key_file..."
      sudo apt-key add "$key_file"
   fi
   # change directory back to previous one
   echo -n "changing directory back to " && cd -
}

