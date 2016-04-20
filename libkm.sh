#!/bin/bash
# --------------------------------------------
# A library of useful shell functions
#
# Author : Keegan Mullaney
# Website: keegoid.com
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

# --------------------------  STRING MANIPULATION

# converts a string to lower case
# $1 -> string to convert to lower case
to_lower() {
    local str=$*
    local output
    echo "${str}"
    output=$(tr '[:upper:]' '[:lower:]' <<< "${str}")
    echo "$output"
}

# trim first character if match is found
# $1 -> string
# $2 -> pattern
trim_first_character_match() {
    echo -n "$(tr -d "$2" <<< ${1:0:1})${1:1}"
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

# print package name and version
# $1 -> package name
# $2 -> package version
print_pkg_info() {
    local pkg="$1"
    local pkg_version="$2"
    local space_count
    local pack_space_count
    local real_space

    space_count="$(( 20 - ${#pkg} ))"
    pack_space_count="$(( 20 - ${#pkg_version} ))"
    real_space="$(( space_count + pack_space_count + ${#pkg_version} ))"
    echo -en " ${GREEN_CHK}"
    printf " $pkg %${real_space}.${#pkg_version}s ${pkg_version}\n"
}

# --------------------------  CHECKS

is_root() {
    #   [ "$(id -u)" -eq 0 ] && return 0 || error "must be root"
    { [ "$EUID" -eq 0 ] && return 0; } || error "must be root"
}

not_installed() {
    dpkg -s "$1" 2>&1 | grep -q 'Version:'
    if [ "$?" -eq 0 ]; then
        apt-cache policy "$1" | grep 'Installed: (none)'
        [ "$?" -eq 0 ] && return 0 || return 1
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
    [ -z "$1" ] && error "${FUNCNAME[1]}(${BASH_LINENO[0]}): Variable not set."
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

gem_must_exist() {
    if ! ~/.rbenv/shims/gem list ^"$1"$ -i >/dev/null; then
        notify2 "$1 must be installed to continue."
        pause "Press [Enter] to install it now" true
        ~/.rbenv/shims/gem install "$1"
        ~/.rbenv/bin/rbenv rehash
    fi
}

npm_must_exist() {
    if ! npm ls -gs | grep -q "${1}@"; then
        notify2 "$1 must be installed to continue."
        pause "Press [Enter] to install it now" true
        sudo npm install -g "$1"
    fi
}

pip_must_exist() {
    if ! pip list | grep -w "$1" >/dev/null 2>&1; then
        notify2 "$1 must be installed to continue."
        pause "Press [Enter] to install it now" true
        sudo -H pip install "$1"
    fi
}

program_must_exist() {
    not_installed "$1"

    if [ "$?" -eq 0 ]; then
        notify2 "$1 must be installed to continue."
        pause "Press [Enter] to install it now" true
        sudo apt-get -y install "$1"
    fi
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
    if [ -n "$scripts" ]; then
        cd "$scripts" || exit

        # get script ready to run
        dos2unix -k -q "${name}"
        chmod +x "${name}"

        # clear the screen and run the script
        [ "$DEBUG_MODE" -eq 1 ] || clear
        . ./"${name}"
        result="$?"
        notify3 "script: ${name} has finished"
        return "$result"

        cd - >/dev/null
    fi
    return 1
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
    local repo_url="$1"
    local conf_file="$2"
    local src_cmd="$4"
    local repo_name
    local repo_dir
    local today

    repo_name=$(trim_longest_left_pattern "$3" "/")
    repo_dir=$(trim_shortest_right_pattern "$3" "/")
    today=$(date +%Y%m%d_%s)

    [ -z "$repo_name" ] && repo_name=$(trim_longest_left_pattern "$repo_dir" "/")

    if [ -n "$repo_name" ]; then
        if [ -d "$repo_dir" ] && grep -q "$repo_name" "$conf_file" >/dev/null 2>&1; then
#            notify "already set $repo_name in $conf_file"
            cd "$repo_dir" && echo "checking for updates: $repo_name" && git pull && cd - >/dev/null
        else
            pause "Press [Enter] to configure $repo_name in $conf_file" true
            [ -d "$repo_dir" ] && notify2 "$repo_dir already exists. Will save a copy, delete and clone again." && cp -r "$repo_dir" "$repo_dir-$today" && rm -rf "$repo_dir"
            git clone "$repo_url" "$repo_dir" && echo -e "$src_cmd" >> "$conf_file" && success "configured: $repo_name in $conf_file"
        fi
    else
        alert "repo_name variable is empty"
    fi

    RET="$?"
    debug
}

# --------------------------  INSTALL FROM PACKAGE MANAGERS

# install packages from a simple list
# $1 -> program list (space-separated)
# $2 -> enable-repo (optional)
install_apt() {
    local names="$1"
    local repo="$2"

    # install applications in the list
    for pkg in $names; do
        if not_installed "$pkg"; then
            echo
            read -p "Press [Enter] to install $pkg..."
            if [ -z "${repo}" ]; then
                sudo apt-get -y install "$pkg"
            else
                sudo apt-add-repository "${repo}"
                sudo apt-get update
                sudo apt-get -y install "$pkg"
            fi
        fi
    done
}

# install gems from a simple list
# $1 -> gem list (space-separated)
install_gem() {
    local names="$1"

    # make sure ruby is installed
    program_must_exist "ruby"
#    program_must_exist "rubygems-integration"

    # install gems in the list
    for pkg in $names; do
        if ! gem list "$pkg" -i >/dev/null 2>&1; then
            echo
            read -p "Press [Enter] to install $pkg..."
            gem install "$pkg"
        fi
    done
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
    for pkg in $names; do
        if ! npm ls -gs | grep -qw "$pkg"; then
            echo
            read -p "Press [Enter] to install $pkg..."
            sudo npm install -g "$pkg"
        fi
    done
}

# install pips from a simpe list
# $1 -> pip list (space-separated)
install_pip() {
    local names="$1"

    # make sure dependencies are installed
    program_must_exist "python-pip"
    program_must_exist "python-keyring"

    # install pips in the list
    for pkg in $names; do
        pkg=$(trim_longest_right_pattern "$pkg" "[")
        if ! pip list | grep "$pkg" >/dev/null 2>&1; then
            echo
            read -p "Press [Enter] to install $pkg..."
            sudo -H pip install "$pkg"
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
            "Yes")  break;;
            "No")   echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
                    echo "of your GitHub account."
                    echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
                    echo
                    cat "${ssh_dir}/id_rsa.pub";;
            *)      echo "case not found, try again..."
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
    local apt_keys="$HOME/.apt_keys"
    local key_file
    local key_id

    key_file=$(trim_longest_left_pattern "${url}" /)

    [ -z "${url}" ] && alert "missing URL to public key" && return 1
    pause "Press [Enter] to download and import the GPG Key"
    mkdir -pv "$apt_keys"
    (
        cd "$apt_keys" || exit
        #   echo "changing directory to $_"
        # download key
        wget -nc "$url"
        # get key id
        key_id=$(gpg2 --throw-keyids "$key_file" | cut -c 12-19 | tr -d '\n' | tr -d ' ')
        echo "found key: $key_id"
        # import key if it doesn't exist
        if ! apt-key list | grep -w "$key_id"; then
            echo "Installing GPG public key with ID $key_id from $key_file..."
            sudo apt-key add "$key_file"
        fi
    )
}

# --------------------------  GIT FUNCTIONS

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
create_branch() {
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
merge_upstream() {
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

