#!/bin/bash
# --------------------------------------------
# Install / update packages via APT
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keegan@kmauthorized.com
# License: keegoid.mit-license.org
#
# Attributions:
# package install functions & lists
# github.com/Varying-Vagrant-Vagrants/VVV/
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  MISSING PROGRAM CHECKS

# install lists (perform install)
apt_install_list=()

# check lists (check if installed)
apt_check_list=()

# --------------------------  CHECK FOR MISSING PROGRAMS

# loop through check list and add missing packages to install list
qc_apt_check() {
	local pkg
	local pkg_version

	for pkg in "${apt_check_list[@]}"
	do
		if lkm_not_installed "$pkg"; then
			echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
			apt_install_list+=($pkg)
		else
			pkg_version=$(dpkg -s "${pkg}" 2>&1 | grep 'Version:' | cut -d " " -f 2)
			lkm_print_pkg_info "$pkg" "$pkg_version"
		fi
	done

	RET="$?"
	lkm_debug
}

# --------------------------  INSTALL MISSING PROGRAMS

# loop through install list and install any packages that are in the list
# $1 -> to update sources or not
qc_apt_install() {
	qc_apt_check

	if [[ "${#apt_install_list[@]}" -eq 0 ]]; then
		lkm_notify "No packages to install"
	else
		# update all of the package references before installing anything
		if [ "${1}" -eq 0 ]; then
			lkm_pause "Press [Enter] to update Ubuntu sources" true
			sudo apt-get -y update
		fi

		# install packages in the list
		lkm_pause "Press [Enter] to install apt packages"
		# shellcheck disable=SC2068
		sudo apt-get -y install ${apt_install_list[@]}

		# clean up apt caches
		sudo apt-get clean
	fi

	RET="$?"
	lkm_debug
}

# add git lfs from packagecloud.io to add large file support to git
qc_git_lfs() {
	lkm_confirm "Install git-lfs?" true
	RET="$?"
	if [ $RET -eq 0 ]; then
		if lkm_not_installed 'git-lfs'; then
			curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | os=debian dist=xenial sudo -E sudo bash
			lkm_program_must_exist 'git'
			lkm_install_apt 'git-lfs'
			git lfs install
		else
			lkm_notify "git-lfs is already installed"
		fi
	fi

	RET="$?"
	lkm_debug
}

# --------------------------  64-BIT ARCHITECTURE

 UPDATE=0
# SKIP=1
# if [ "$(dpkg --print-foreign-architectures)" = "i386" ]; then
#   dpkg --get-selections | grep i386 || lkm_notify "no i386 packages installed" && SKIP=0
#   if [ "$SKIP" -eq 0 ]; then
#     lkm_pause "Press [Enter] to continue"
#   else
#     lkm_pause "Press [Enter] to purge all i386 packages and remove the i386 architecture" true
#     sudo apt-get purge ".*:i386" && sudo dpkg --remove-architecture i386 && sudo apt-get update && lkm_success "Success, goodbye i386!" && UPDATE=1
#   fi
# fi

# --------------------------  DEFAULT APT PACKAGES

DEFAULT_WORKSTATION_LIST='arp-scan apt-transport-https autojump git gnupg2 figlet links mutt net-tools pinta syncthing tree vlc x11vnc xclip'
DEFAULT_DEV_LIST='autoconf automake build-essential byobu checkinstall dconf-cli shellcheck silversearcher-ag tidy tilix xdotool vim-gtk yamllint'

# --------------------------  PROMPT FOR PROGRAMS

lkm_notify3 "The following default packages can be modified prior to installation."
echo
echo "WORKSTATION"
echo "DEVELOPER"
echo
lkm_notify "Workstation packages to install (delete all to skip)"
read -rep "   : " -i "$DEFAULT_WORKSTATION_LIST" APTS1
lkm_notify "Developer packages to install"
read -rep "   : " -i "$DEFAULT_DEV_LIST" APTS2

# --------------------------  ARRAY ASSIGNMENTS

# add packages to check
apt_check_list+=($APTS1)
apt_check_list+=($APTS2)

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the install script
qc_reset() {
	unset -f qc_reset qc_apt_install qc_apt_check qc_git_lfs
}

# --------------------------  INSTALL PROGRAMS

qc_apt_install "$UPDATE"
qc_git_lfs
qc_reset

} # this ensures the entire script is downloaded #
