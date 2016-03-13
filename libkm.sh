#!/bin/bash
# --------------------------------------------
# A library of useful shell functions
#
# Author : Keegan Mullaney
# Website: http://keegoid.com
# Email  : keeganmullaney@gmail.com
#
# http://keegoid.mit-license.org
#
# package install functions:
# https://github.com/Varying-Vagrant-Vagrants/VVV/
#
# some message and check functions:
# https://github.com/spf13/spf13-vim
# --------------------------------------------

# note: true=0 and false=1 in bash

source colors.sh

# --------------------------  DECLARE VARIABLES

# install lists (perform install)
apt_install_list=()
gem_install_list=()
npm_install_list=()
pip_install_list=()

# check lists (check if installed)
apt_check_list=()
gem_check_list=()
npm_check_list=()
pip_check_list=()

# names and versions of repositories/software
SN=( RUBY   SUBL )
SV=( 2.2.3  3103 )

# URLs to check software versions for latest versions
#    RUBY   www.ruby-lang.org/en/downloads/
#    SUBL   https://www.sublimetext.com/3

# verstion variable assignments (determined by array order)
RUBY_V="${SV[0]}"
SUBL_V="${SV[1]}"

# software download URLs
RUBY_URL="https://get.rvm.io"
SUBL_URL="https://download.sublimetext.com/sublime-text_build-${SUBL_V}_amd64.deb"
WORDPRESS_URL="http://wordpress.org/latest.tar.gz"

# GPG public keys
RUBY_KEY='D39DC0E3'

# --------------------------  STRING MANIPULATION

# converts a string to lower case
# $1 -> string to convert to lower case
to_lower() {
    local str="$@"
    local output     
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    echo $output
}

# trim first character if match is found
# $1 -> string
# $2 -> match
trim_first_character_match() {
   echo -n "$(echo ${1:0:1} | tr -d ${2})${1:1}"
}

# trim shortest pattern from the left
# $1 -> string
# $2 -> pattern
trim_shortest_left_pattern() {
   echo -n "${1#*$2}"
   # -n (don't create newline character)
}

# trim longest pattern from the left
# $1 -> string
# $2 -> pattern
trim_longest_left_pattern() {
   echo -n "${1##*$2}"
}

# trim shortest pattern from the right
# $1 -> string
# $2 -> pattern
trim_shortest_right_pattern() {
   echo -n "${1%$2*}"
}

# trim longest pattern from the right
# $1 -> string
# $2 -> pattern
trim_longest_right_pattern() {
   echo -n "${1%%$2*}"
}

# --------------------------  MESSAGES

msg() {
   echo -e "$1"
}

debug() {
   if [ "$DEBUG_MODE" -eq 1 ] && [ "$RET" -gt 0 ]; then
#      alert "An error occurred in function ${FUNCNAME[1]} on line ${BASH_LINENO[0]}."
      alert "${FUNCNAME[1]}(${BASH_LINENO[0]}): An error has occurred."
   fi
}

success() {
   if [ -z "$RET" ] || [ "$RET" -eq 0 ]; then
      msg "${GREEN_CHK} ${1}${2}"
   fi
}

error() {
   msg "${RED_X} ${1}${2}"
   exit 1
}

alert() {
   msg "${RED_BLACK} ${1}${2} ${NONE_WHITE}"
   pause
}

notify() {
   msg "${GRAY_BLACK} ${1}${2} ${NONE_WHITE}"
}

notify2() {
   msg "${YELLOW_BLACK} ${1}${2} ${NONE_WHITE}"
}

notify3() {
   msg "${BLUE_BLACK} ${1}${2} ${NONE_WHITE}"
}

script_name() {
#   echo "$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
   echo -n "$1" && trim_longest_left_pattern "$0" "/" && echo "$2"
}

# --------------------------  CHECKS

is_root() {
#   [ "$(id -u)" -eq 0 ] && return 0 || error "must be root"
   [ "$EUID" -eq 0 ] && return 0 || error "must be root"
}
 
not_installed() {
   if [ "$(dpkg -s ${1} 2>&1 | grep 'Version:')" ]; then
      [ -n "$(apt-cache policy ${1} | grep 'Installed: (none)')" ] && return 0 || return 1
   else
      return 0
   fi
}

user_exists() {
   # -q (quiet), -w (only match whole words, otherwise "user" would match "user1" and "user2")
   if grep -qw "^${1}" /etc/passwd; then
      return 0
   else
      return 1
   fi
}

variable_set() {
   [ -z "$1" ] && error "You must have your HOME environmental variable set to continue."
}

# --------------------------  PROMPTS

pause() {
   local prompt="$1"
   local back="$2"
   # default message
   [ -z "${prompt}" ] && prompt="Press [Enter] key to continue"
   # how to go back, with either default or user message
   [ "$back" = true ] && prompt="${prompt}, [Ctrl+Z] to go back" 
   read -p "$prompt..."
}

confirm() {
   local text="$1"
   local preferYes="$2" # optional

   # check preference
   if [ -n "${preferYes}" ] && [ "${preferYes}" = true ]; then
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

program_must_exist() {
   not_installed $1

   # throw error on non-zero return value
   if [ "$?" -eq 0 ]; then
      notify2 "You must have $1 installed to continue."
      pause "Press [Enter] to install it now" true
      sudo apt-get -y install "$1"
    fi
}

# loop through check list and add missing packages to install list
apt_check() {
   local pkg
   local pkg_version

   for pkg in "${apt_check_list[@]}"; do
      if not_installed $pkg; then
         echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
         apt_install_list+=($pkg)
      else
         pkg_version=$(dpkg -s "${pkg}" 2>&1 | grep 'Version:' | cut -d " " -f 2)
         space_count="$(expr 20 - "${#pkg}")"
         pack_space_count="$(expr 20 - "${#pkg_version}")"
         real_space="$(expr ${space_count} + ${pack_space_count} + ${#pkg_version})"
         echo -en " ${GREEN_CHK}"
         printf " $pkg %${real_space}.${#pkg_version}s ${pkg_version}\n"
      fi
   done
}

# loop through check list and add missing gems to install list
gem_check() {
   local pkg
   local pkg_version

   for pkg in "${gem_check_list[@]}"; do
      if gem list $pkg -i >/dev/null; then
         pkg_version=$(gem list "${pkg}" | grep "${pkg}" | cut -d " " -f 2 | cut -d "(" -f 2 | cut -d ")" -f 1)
         space_count="$(expr 20 - "${#pkg}")"
         pack_space_count="$(expr 20 - "${#pkg_version}")"
         real_space="$(expr ${space_count} + ${pack_space_count} + ${#pkg_version})"
         echo -en " ${GREEN_CHK}"
         printf " $pkg %${real_space}.${#pkg_version}s ${pkg_version}\n"
      else
         echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
         gem_install_list+=($pkg)
      fi
   done
}

# loop through check list and add missing npms to install list
npm_check() {
   local pkg
   local pkg_version

   for pkg in "${npm_check_list[@]}"; do
      if npm ls -gs | grep -q "$pkg"; then
         pkg_version=$(npm ls -gs | grep "${pkg}" | cut -d "@" -f 2)
         space_count="$(expr 20 - "${#pkg}")"
         pack_space_count="$(expr 20 - "${#pkg_version}")"
         real_space="$(expr ${space_count} + ${pack_space_count} + ${#pkg_version})"
         echo -en " ${GREEN_CHK}"
         printf " $pkg %${real_space}.${#pkg_version}s ${pkg_version}\n"
      else
         echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
         npm_install_list+=($pkg)
      fi
   done
}

# loop through check list and add missing pips to install list
pip_check() {
   local pkg
   local pkg_trim
   local pkg_version

   for pkg in "${pip_check_list[@]}"; do
      pkg_trim=$(trim_longest_right_pattern "$pkg" "[")
      if pip list | grep "$pkg_trim" >/dev/null 2>&1; then
         pkg_version=$(pip list | grep "${pkg_trim}" | cut -d " " -f 2 | tr -d "(" | tr -d ")")
         space_count="$(expr 20 - "${#pkg}")"
         pack_space_count="$(expr 20 - "${#pkg_version}")"
         real_space="$(expr ${space_count} + ${pack_space_count} + ${#pkg_version})"
         echo -en " ${GREEN_CHK}"
         printf " $pkg %${real_space}.${#pkg_version}s ${pkg_version}\n"
      else
         echo -e " ${YELLOW_BLACK} * $pkg_trim [not installed] ${NONE_WHITE}"
         pip_install_list+=($pkg)
      fi
   done
}

# --------------------------  CUSTOM SOFTWARE

# set software versions
# $1 -> software list (space-separated)
function set_software_versions()
{
   local swl="$1"
   local version
   echo
   for ((i=0; i<${#SN[@]}; i++)); do
      if echo $swl | grep -qw "${SN[i]}"; then
         read -ep "Enter software version for ${SN[i]}: " -i "${SV[i]}" version
         SV[i]="$version"
      fi
   done
}

# download and extract software
# $1 -> list of URLs to software (space-separated)
function get_software()
{
   local list="$1"
   local name

   echo
   for url in ${list}; do
      name=$(trim_longest_left_pattern $url "/")
      pause "Press enter to download and extract: $name"
      wget -nc $url
      tar -xzf $name
   done
}

# --------------------------  MISC ACTIONS

# create symlink if source file exists
lnif() {
   if [ -e "$1" ]; then
      ln -sf "$1" "$2"
   fi
   RET="$?"
   debug
}

# run a script from another script
# $1 -> name of script to be run
# $2 -> script directory
run_script() {
   local name="$1"
   local scripts="$2"
   local result

   # make sure dos2unix is installed
   program_must_exist "dos2unix"

   # change to scripts directory to run scripts
   [ -n "$scripts" ] && cd $scripts

   # get script ready to run
   dos2unix -k -q "${name}"
   chmod +x "${name}"

   # clear the screen and run the script
   [ "$DEBUG_MODE" -eq 1 ] || clear
   . ./"${name}"
   result=$?
   notify3 "script: ${name} has finished"

   # change back to original directory
   [ -n "$scripts" ] && cd - >/dev/null

   return $result
}

# append source cmd to conf file if not set already
set_source_cmd() {
   local conf_file="$1"
   local match="$2"
   local src_cmd="$3"

   if grep -q "$match" "$conf_file" >/dev/null 2>&1; then
      notify "already set $match in $conf_file"
   else
      echo "$src_cmd" >> "$conf_file" && success "configured: $match in $conf_file"
   fi

   RET="$?"
   debug
}

# clone or pull git repo and source repo name in conf file
set_sourced_config() {
   local conf_file="$1"
   local repo_url="$2"
   local repo_name=$(trim_longest_left_pattern "$3" "/")
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local src_cmd="$4"
   local today=`date +%Y%m%d_%s`

   [ -z "$repo_name" ] && repo_name=$(trim_longest_left_pattern "$repo_dir" "/")

   if [ -n "$repo_name" ]; then
      if [ -d "$repo_dir" ] && [ -n "$(grep $repo_name $conf_file)" ]; then
         notify "already set $repo_name in $conf_file"
         cd $repo_dir && echo "checking for updates: $repo_name" && git pull && cd - >/dev/null
      else
         pause "Press [Enter] to configure $repo_name in $conf_file" true
         [ -d "$repo_dir" ] && notify2 "$repo_dir already exists. Will save a copy, delete and clone again." && cp -r $repo_dir $repo_dir-$today && rm -rf $repo_dir
         git clone "$repo_url" "$repo_dir" && echo -e "$src_cmd" >> "$conf_file" && success "configured: $repo_name in $conf_file"
      fi
   else
      alert "repo_name variable is empty"
   fi

   RET="$?"
   debug
}

# clone or pull git repo and copy repo file onto conf file
set_copied_config() {
   local conf_file="$1"
   local repo_url="$2"
   local repo_file="$3"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local today=`date +%Y%m%d_%s`

   if [ -n "$repo_file" ]; then
      if [ -f $repo_file ]; then
         notify "already set $repo_file in $conf_file"
         cd $repo_dir && echo "checking for updates: $repo_file" && git pull && cp $repo_file $conf_file && success "updated: $conf_file" && cd - >/dev/null
      else
         pause "Press [Enter] to configure $conf_file" true
         [ -d "$repo_dir" ] && notify2 "$repo_dir already exists. Will save a copy, delete and clone again." && cp -r $repo_dir $repo_dir-$today && rm -rf $repo_dir
         git clone "$repo_url" "$repo_dir" && cp $repo_file $conf_file && success "configured: $conf_file"
      fi
   else
      alert "repo_file variable is empty"
   fi

   RET="$?"
   debug
}

# source rvm after installing non-package management version of ruby
source_rvm() {
   echo
   read -p "Press [Enter] to start using rvm..."
   if grep -q "/usr/local/rvm/scripts/rvm" $HOME/.bashrc; then
      source /usr/local/rvm/scripts/rvm && echo "sourced rvm"
   else
      echo "source /usr/local/rvm/scripts/rvm" >> $HOME/.bashrc
      source /usr/local/rvm/scripts/rvm && echo "rvm sourced and added to .bashrc"
   fi

   RET="$?"
   debug
}

# --------------------------  INSTALL FROM CUSTOM SCRIPTS

install_rvm_ruby() {
   pause "Press [Enter] to install ruby via rvm" true
   if ! ruby -v | grep -q "ruby ${RUBY_V}"; then
      gpg2 --keyserver hkp://keys.gnupg.net --recv-keys "$RUBY_KEY"
      curl -sSL "$RUBY_URL" | bash -s stable --ruby="${RUBY_V}"
   fi
   source_rvm
}

install_rbenv_ruby() {
   # rbenv
   set_sourced_config   "$HOME/.profile" \
                        "https://github.com/rbenv/rbenv.git" \
                        "$HOME/.rbenv/" \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/bin:" ]] || PATH="$HOME/.rbenv/bin:$PATH"'

   # optional, to speed up rbenv
   [ -d "$HOME/.rbenv" ] && cd "$HOME/.rbenv" && src/configure && make -C src && cd - >/dev/null

   # add rbenv init - command to .profile
   set_source_cmd       "$HOME/.profile" \
                        '"eval "$(rbenv init -)"' \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/shims:" ]] || eval "$(rbenv init -)"'

   # ruby-build
   set_sourced_config   "$HOME/.profile" \
                        "https://github.com/rbenv/ruby-build.git" \
                        "$HOME/.rbenv/plugins/ruby-build/" \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/plugins/ruby-build/bin:" ]] || PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'

   # tell rubygems not to install docs for each package locally
   set_source_cmd       "$HOME/.gemrc" \
                        'gem: --no-ri --no-rdoc' \
                        'gem: --no-ri --no-rdoc'

   source "$HOME/.profile"

   # check that rbenv is working
   type rbenv
   rbenv version

   # install ruby
   [ "$?" -eq 0 ] && rbenv install 2.2.3
   [ "$?" -eq 0 ] && rbenv global 2.2.3

   # check ruby and rubygem versions
   ruby -v
   gem env home

   RET="$?"
   debug
}

# install the keybase cli client
install_keybase() {
   if not_installed "keybase"; then
      # change to tmp directory to download file and then back to original directory
      cd /tmp
      curl -O https://dist.keybase.io/linux/deb/keybase-latest-amd64.deb && sudo dpkg -i keybase-latest-amd64.deb
      cd - >/dev/null
   else
      notify "keybase is already installed"
   fi
}

# install the Sublime Text
install_subl() {
   if not_installed "subl"; then
      # change to tmp directory to download file and then back to original directory
      cd /tmp
      echo "downloading subl..."
      curl -O "https://download.sublimetext.com/sublime-text_build-${SUBL_V}_amd64.deb" && sudo dpkg -i "sublime-text_build-${SUBL_V}_amd64.deb" && success "successfully installed: subl"
      cd - >/dev/null
      # set sublime-text as default text editor
      sudo sed -i.bak "s/gedit/sublime_text/" /etc/gnome/defaults.list
   else
      notify "subl is already installed"
   fi
}

# install or update spf13-vim
install_spf13_vim() {
   [ -d "$HOME/.spf13-vim-3" ] && echo "updating spf13-vim..." || echo "installing spf13-vim..."
   # change to tmp directory to download file and then back to original directory
   cd /tmp
   curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh && success "successfully configured: $HOME/.spf13-vim-3"
   cd - >/dev/null
}

# install or update LXD for LXC containers
install_lxd() {
   program_must_exist lxc
   if not_installed lxd; then
      sudo add-apt-repository -y ppa:ubuntu-lxc/lxd-stable && sudo sed -i.bak -e "/trusty-backports/ s/^# //" /etc/apt/sources.list && sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y -t trusty-backports install lxd criu && success "successfuly installed: LXD (\"lex-dee\")" && notify2 "You must log out and log back in for lxc command to work."
   else
      notify "already installed LXD"
   fi
}

# create a base alpine linux image for LXD
create_alpine_lxd_image() {
   local repo_url="$1"
   local repo_name=$(trim_longest_left_pattern "$2" "/")
   local repo_dir=$(trim_shortest_right_pattern "$2" "/")
   local image_name="alpine-latest"
   local image_cnt

   [ -z "$repo_name" ] && repo_name=$(trim_longest_left_pattern "$repo_dir" "/")

   # update or clone alpine-lxd-image repo
   if [ -d "$repo_dir" ]; then
      notify "already set $repo_name"
      cd $repo_dir && echo "checking for updates: $repo_name" && git pull && cd - >/dev/null
   else
      pause "Press [Enter] to configure $repo_name" true
      git clone "$repo_url" "$repo_dir" && success "configured: $repo_name"
   fi

   not_installed lxd && install_lxd

   # count number of matches for alpine-latest and add one
   image_cnt=$(lxc image list | grep -c $image_name)
   LXD_IMAGE="$image_name-$image_cnt"

   cd "$repo_dir"
   # remove any previous images
   sudo rm alpine-v*.tar.gz >/dev/null 2>&1
   # download and build the latest alpine image
   sudo ./build-alpine
   # set permissions
   sudo chmod 664 alpine-v*.tar.gz
   # add newly created image to lxc
   [ -f alpine-v*.tar.gz ] && lxc image import alpine-v*.tar.gz --alias "$LXD_IMAGE" && success "successfully created alpine linux lxd image and imported into lxc"
   cd - >/dev/null
}

# create new lxd container from latest image
create_lxd_container() {
   local image_name="alpine-latest"
   local image_cnt=`expr $(lxc image list | grep -c $image_name) - 1`
   local selected_image
   local container_name
   local host_name

   # set image name if not already set
   [ -z "$LXD_IMAGE" ] && LXD_IMAGE="$image_name-$image_cnt"

   # select an image and choose a container name
   lxc image list
   read -ep "Select an image to use for the new container: " -i "$LXD_IMAGE" selected_image
   read -ep "Enter a container name to use with $selected_image: " -i "alpine-wp-${image_cnt}" container_name
   read -ep "Enter a host name to use with /etc/hosts: " -i "${container_name}.dev" host_name

   # create and start container
   lxc launch "$selected_image" "$container_name"

   # add container's ip to /etc/hosts
   pause "Press [Enter] to add $host_name to /etc/hosts"
   local ipv4=$(lxc list | grep $container_name | cut -d "|" -f 4 | cut -d " " -f 2)
   # remove entry if it already exists
   if cat /etc/hosts | grep "$host_name" >/dev/null; then
      sudo sed -i.bak "/$host_name/d" /etc/hosts
   fi
   # wait for ip address to get assigned to container
   while [ -z "$ipv4" ]; do
      notify3 "The container hasn't been assigned an IP address yet."
      pause "Press [Enter] to try again" true
      ipv4=$(lxc list | grep $container_name | cut -d "|" -f 4 | cut -d " " -f 2)
   done
   # add new hosts entry
   [ -n "$ipv4" ] && echo -e "${ipv4}\t${host_name}" | sudo tee --append /etc/hosts && success "successfully added ${ipv4} and ${host_name} to /etc/hosts" || notify2 "Couldn't add ${host_name} to /etc/hosts, missing IP address on container."

   # set global container name variable
   LXD_CONTAINER="$container_name"

   RET="$?"
   debug
}

# configure lxd container for syncing and ssh with host
# $1 -> repos directory
# $2 -> is this a server?
configure_lxd_container() {
   local image_cnt=`expr $(lxc image list | grep -c alpine-latest) - 1`
   local selected_container
   local relative_source
   local target_dir
   local source_dir
   local target_dir_root

   # set container name if not already set
   [ -z "$LXD_CONTAINER" ] && LXD_CONTAINER="alpine-wp-${image_cnt}"

   # select a container and set syncing directory paths
   lxc list
   read -ep "Select a container to configure: " -i "$LXD_CONTAINER" selected_container
   read -ep "Choose a source directory on host to sync: ~/${1}/" -i "sites/${selected_container}/site" relative_source
   read -ep "Choose a target directory in container to sync: /" -i "srv/www/${selected_container}/current" target_dir
   source_dir="$HOME/${1}/$relative_source"
   target_dir="/${target_dir}"

   pause "Press [Enter] to configure shared directory between host and container"
   # make source and target directories and configure with proper permissions
   mkdir -p "$source_dir"
   sudo chgrp 165536 "$source_dir"
   sudo chmod g+s "$source_dir"
#   sudo setfacl -d -m u:lxd:rwx,u:$(logname):rwx,u:165536:rwx,g:lxd:rwx,g:$(logname):rwx,g:165536:rwx "$source_dir"
   lxc exec "${selected_container}" -- su - root -c "mkdir -p $target_dir"
   # check if device already exists and remove it if it does
   if lxc config device list "${selected_container}" >/dev/null | grep "shared-dir-${image_cnt}"; then
      lxc config device remove "${selected_container}" "shared-dir-${image_cnt}"
   fi
   # add new device for shared directory
   lxc config device add "${selected_container}" "shared-dir-${image_cnt}" disk source="$source_dir" path="$target_dir" && success "Successfully configured syncing of $source_dir on host with $target_dir in container."

   # if not a server
   if [ "${2}" -eq 1 ]; then
      # if no ssh key, generate one
      [ -f "$HOME/.ssh/id_rsa.pub" ] || gen_ssh_key $HOME/.ssh $(logname)
      pause "Press [Enter] to copy public your ssh key to \"authorized_keys\" in container"
      # make .ssh directory if it doesn't exist
      lxc exec "${selected_container}" -- su - root -c "mkdir -p .ssh"
      # push public ssh key to container
      lxc file push "$HOME/.ssh/id_rsa.pub" "${selected_container}/root/.ssh/authorized_keys" && success "Successfully added ssh key to ${selected_container}."
   fi

   RET="$?"
   debug
}

# install newer version of virtualbox
install_virtualbox() {
   if not_installed "virtualbox-5.0"; then
      # add virtualbox to sources list if not already there
      if ! grep -q "virtualbox" /etc/apt/sources.list; then
         sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
         echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" | sudo tee --append /etc/apt/sources.list
      fi
      # add signing key
      wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
      # update sources and install the latest virtualbox
      sudo apt-get update
      install_apt "virtualbox-5.0"
   fi

   RET="$?"
   debug
}

# install newer version of vagrant
install_vagrant() {
   if not_installed "vagrant"; then
      # change to tmp directory to download file and then back to original directory
      cd /tmp
      echo "downloading vagrant..."
      curl -O https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb && sudo dpkg -i vagrant_1.8.1_x86_64.deb && success "successfully installed: vagrant"
      cd - >/dev/null
   fi
   # install vagrant-hostsupdater
   [ -z "$(vagrant plugin list | grep hostsupdater)" ] && echo -e "${LIGHT_GRAY} NOTE: a vpn may be required in China for this... ${STD}" && vagrant plugin install vagrant-hostsupdater
   # install vagrant-triggers
   [ -z "$(vagrant plugin list | grep triggers)" ] && echo -e "${LIGHT_GRAY} NOTE: a vpn may be required in China for this... ${STD}" && vagrant plugin install vagrant-triggers

   RET="$?"
   debug
}

# --------------------------  INSTALL FROM PACKAGE MANAGERS

# loop through install list and install any packages that are in the list
# $1 -> to update sources or not
apt_install() {
   apt_check

   if [[ "${#apt_install_list[@]}" -eq 0 ]]; then
      notify "No packages to install"
   else
      # update all of the package references before installing anything
      if [ "${1}" -eq 0 ]; then
         pause "Press [Enter] to update Ubuntu sources" true
         sudo apt-get -y update
      fi

      # install packages in the list
      read -p "Press [Enter] to install apt packages..."
      sudo apt-get -y install ${apt_install_list[@]}

      # clean up apt caches
      sudo apt-get clean
   fi
}

# install packages from a simple list
# $1 -> program list (space-separated)
# $2 -> enable-repo (optional)
install_apt() {
   local names="$1"
   local repo="$2"

   # install applications in the list
   for apt in $names; do
      if not_installed $apt; then
         echo
         read -p "Press [Enter] to install $apt..."
         [ -z "${repo}" ] && sudo apt-get -y install "$apt" || { sudo apt-add-repository "${repo}"; sudo apt-get update; sudo apt-get -y install "$apt"; }
      fi
   done
}

# loop through install list and install any gems that are in the list
gem_install() {
   gem_check

   # make sure ruby is installed
   program_must_exist "ruby"
   program_must_exist "rubygems-integration"

   if [[ "${#gem_install_list[@]}" -eq 0 ]]; then
      notify "No gems to install"
   else
      # install required gems
      pause "Press [Enter] to install gems" true
      gem install ${gem_install_list[@]}
   fi
}

# install gems from a simple list
# $1 -> gem list (space-separated)
install_gem() {
   local names="$1"

   # make sure ruby is installed
   program_must_exist "ruby"
   program_must_exist "rubygems-integration"

   # install gems in the list
   for app in $names; do
      if ! $(gem list "$app" -i); then
         echo
         read -p "Press [Enter] to install $app..."
         gem install "$app"
      fi
   done
}

# loop through install list and install any npms that are in the list
npm_install() {
   npm_check

   # make sure npm is installed
   program_must_exist "npm"
   # symlink nodejs to path
   if [ ! -L /usr/bin/node ]; then
      sudo ln -s "$(which nodejs)" /usr/bin/node
   fi

   if [[ "${#npm_install_list[@]}" -eq 0 ]]; then
      notify "No npms to install"
   else
      # install required npms
      pause "Press [Enter] to install npms" true
      sudo npm install -g ${npm_install_list[@]}
   fi
}

# install npms from a simple list
# $1 -> npm list (space-separated)
install_npm() {
   local names="$1"

   # make sure npm is installed
   program_must_exist "npm"
   # symlink nodejs to path
   if [ ! -L /usr/bin/node ]; then
      sudo ln -s "$(which nodejs)" /usr/bin/node
   fi

   # install npm packages in the list
   for app in $names; do
      if ! npm ls -gs | grep -qw "$app"; then
         echo
         read -p "Press [Enter] to install $app..."
         sudo npm install -g "$app"
      fi
   done
}

# loop through install list and install any pips that are in the list
pip_install() {
   pip_check

   # make sure dependencies are installed
   program_must_exist "python-pip"
   program_must_exist "python-keyring"

   if [[ "${#pip_install_list[@]}" -eq 0 ]]; then
      notify "No pips to install"
   else
      # install required pips
      pause "Press [Enter] to install pips" true
      sudo -H pip install ${pip_install_list[@]}
   fi
}

# install pips from a simpe list
# $1 -> pip list (space-separated)
install_pip() {
   local names="$1"

   # make sure dependencies are installed
   program_must_exist "python-pip"
   program_must_exist "python-keyring"

   # install pips in the list
   for app in $names; do
      app=$(trim_longest_right_pattern "$app" "[")
      if ! pip list | grep "$app" >/dev/null 2>&1; then
         echo
         read -p "Press [Enter] to install $app..."
         sudo pip install "$app"
      fi
   done
}

# --------------------------  SSH AND GPG KEYS...(in other words, FUN)

# ssh key for connecting to remote server
# $1 -> SSH directory
# $2 -> non-root Linux username
gen_ssh_key() {
   local ssh_dir="$1"
   local u="$2"

   echo
   notify3 "Note: ${ssh_dir} is for public/private key pairs to establish SSH connections to remote systems"
   echo
   # check if id_rsa exists
   if [ -f "${ssh_dir}/id_rsa" ]; then
      notify "${ssh_dir}/id_rsa already exists"
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
      pause
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

# ssh key for authenticating incoming connections on remote host
# $1 -> SSH directory
# $2 -> non-root Linux username
authorized_ssh_key() {
   local ssh_dir="$1"
   local u="$2"
   local ssh_rsa

   echo
   echo "Note: ${ssh_dir}/authorized_keys are public keys to establish"
   echo "incoming SSH connections to a server"
   echo
   if [ -f "${ssh_dir}/authorized_keys" ]; then
      notify "${ssh_dir}/authorized_keys already exists for ${u}"
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

# import public GPG key if it doesn't already exist in list of RPM keys
# although rpm --import won't import duplicate keys, this is a proof of concept
# $1 -> URL of the public key file
# return: false if URL is empty, else true
get_public_key() {
   local url="$1"
   local apt_keys="$HOME/apt_keys"

   [ -z "${url}" ] && alert "missing URL to public key" && return 1
   pause "Press [Enter] to download and import the GPG Key"
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

# --------------------------  GIT SHIT

#   $1 -> code author's name
#   $2 -> code author's email
#   $3 -> editor to use for git
configure_git()
{
   local name="$1"
   local email="$2"
   local editor="$3"

   # specify a user
   git config --global user.name "$name"
   git config --global user.email "$email"
   # select a text editor
   git config --global core.editor "$editor"
   # set default push and pull behavior to the old method
   git config --global push.default matching
   git config --global pull.default matching
   # create a global .gitignore file
   git config --global core.excludesfile "$HOME/.gitignore_global"
   pause "Press [Enter] to view the config"
   git config --list
}

#   $1 -> GitHub username
#   $2 -> name of upstream repository
#   $3 -> location of Repos directory
#   $4 -> use SSH protocal for git operations? (optional)
clone_repo()
{
   local github_user="$1"
   local address="${github_user}/$2.git"
   local repos_dir="$3"
   local use_ssh=$4

   [ -z "${use_ssh}" ] && use_ssh=false

   if [ -d "${repos_dir}/${2}" ]; then
      notify "${2} directory already exists, skipping clone operation..."
   else
      echo
      notify2 "*** NOTE ***"
      notify2 "Make sure \"github.com/${address}\" exists."
      pause "Press [Enter] to clone ${address} at GitHub"
      if [ "$use_ssh" = true ]; then
         git clone "git@github.com:${address}"
      else
         git clone "https://github.com/${address}"
      fi
   fi

   # change to newly cloned directory
   cd "${2}"
   echo "changing directory to $_"
}

#   $1 -> GitHub username
#   $2 -> name of origin repository
#   $3 -> set remote upstream or origin (true for upstream)
#   $4 -> use SSH protocal for git operations? (optional)
set_remote_repo()
{
   local github_user="$1"
   local address="${github_user}/$2.git"
   local set_upstream=$3
   local use_ssh=$4

   [ -z "${use_ssh}" ] && use_ssh=false
   
   if [ "${set_upstream}" = true ] && [ "${github_user}" = 'keegoid' ]; then
#      echo "upstream doesn't exist for $github_user, skipping..."
      echo false
   fi

   if git config --list | grep -q "${address}"; then
      echo
      notify "remote repo already configured: ${address}"
   else
      echo
      if [ "$set_upstream" = true ]; then
         pause "Press [Enter] to assign upstream repository"
         if [ "$use_ssh" = true ]; then
            git remote add upstream "git@github.com:${address}" && echo "remote upstream added: git@github.com:${address}"
         else
            git remote add upstream "https://github.com/${address}" && echo "remote upstream added: https://github.com/${address}"
         fi
      else
         echo
         notify2 "*** NOTE ***"
         notify2 "Make sure \"github.com/${address}\" exists."
         notify2 "Either fork and rename it, or create a new repository in your GitHub."
         pause "Press [Enter] to assign remote origin repository"
         if [ "$use_ssh" = true ]; then
            git remote add origin "git@github.com:${address}" && echo "remote origin added: git@github.com:${address}"
         else
            git remote add origin "https://github.com/${address}" && echo "remote origin added: https://github.com/${address}"
         fi
      fi
   fi
}

# create a branch for custom changes so master can receive upstream updates
# upstream changes can then be merged with the branch interactively
# $1 -> branch name
create_branch()
{
   local branch_name="$1"
   
   echo
   pause "Press [Enter] to create a git branch for your site at ${branch_name}"
   git checkout -b "${branch_name}"

   # some work and some commits happen
   # some time passes
   #git fetch upstream
   #git rebase upstream/master or git rebase interactive upstream/master

   echo
   pause "Press [Enter] to push changes and set branch origin in config"
   git push -u origin "${branch_name}"

   echo
   pause "Press [Enter] to checkout the master branch again"
   git checkout master

   # above could also be done with:
   # git branch "${branch_name}"
   # git push origin "${branch_name}"
   # git branch -u "origin/${branch_name}" "${branch_name}"

   echo
   echo "*************************************************************************"
   echo "* - use ${branch_name} branch to make your own site                      "
   echo "* - use master branch to keep up with changes from the upstream repo     "
   echo "*************************************************************************"
}

# add remote upstream repository, fetch and merge changes
merge_upstream()
{
   # pull in changes not present in local repository, without modifying local files
   echo
   pause "Press [Enter] to fetch changes from upstream repository"
   git fetch upstream && echo "upstream fetch done"

   # merge any changes fetched into local working files
   echo
   notify2 "*** NOTE ***"
   notify2 "If merging changes, press \":wq enter\" to accept the merge message in vi."
   pause "Press [Enter] to merge changes"
   git merge upstream/master

   # or combine fetch and merge with:
   #git pull upstream master
}

