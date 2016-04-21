#!/bin/bash

{ # this ensures the entire script is downloaded #

echo "# --------------------------------------------"
echo "# Install and update programs.                "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: keegoid.com                        "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

[ -z "$LTS" ] && LTS=4

# --------------------------  LOCAL FUNCTIONS

qc_has() {
  type "$1" > /dev/null 2>&1
}

# --------------------------  MISSING PROGRAM CHECKS

# install lists (perform install)
apt_install_list=()
gem_install_list=()
npm_install_list=()
pip_install_list=()
pip3_install_list=()

# check lists (check if installed)
apt_check_list=()
gem_check_list=()
npm_check_list=()
pip_check_list=()
pip3_check_list=()

# --------------------------  CUSTOM INSTALL SCRIPTS

# install ruby with rbenv and ruby-build
qc_install_rbenv_ruby() {
    # ruby dependencies
    install_apt "gpgv2 git-core curl zlib1g-dev build-essential libssl-dev libssl1.0.0 libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev"

    # rbenv
    # shellcheck disable=SC2016
    set_sourced_config  "https://github.com/rbenv/rbenv.git" \
                        "$HOME/.bashrc" \
                        "$HOME/.rbenv/" \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/bin:" ]] || PATH="$HOME/.rbenv/bin:$PATH"'

    # optional, to speed up rbenv
    [ -d "$HOME/.rbenv" ] && cd "$HOME/.rbenv" && src/configure && make -C src && cd - >/dev/null

    # add rbenv init - command to .bashrc and .bash_profile (for SublimeLinter)
    # shellcheck disable=SC2016
    set_source_cmd      "$HOME/.bashrc" \
                        'rbenv/shims:' \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/shims:" ]] || eval "$(rbenv init -)"'
    # shellcheck disable=SC2016
    set_source_cmd      "$HOME/.bash_profile" \
                        'rbenv/shims:' \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/shims:" ]] || eval "$(rbenv init -)"'

    # ruby-build
    # shellcheck disable=SC2016
    set_sourced_config  "https://github.com/rbenv/ruby-build.git" \
                        "$HOME/.bashrc" \
                        "$HOME/.rbenv/plugins/ruby-build/" \
                        '[[ ":$PATH:" =~ ":$HOME/.rbenv/plugins/ruby-build/bin:" ]] || PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'

    # tell rubygems not to install docs for each package locally
    set_source_cmd      "$HOME/.gemrc" \
                        'no-rdoc' \
                        'gem: --no-ri --no-rdoc'

    qc_has ~/.rbenv/bin/rbenv || error "rbenv install failed"
    ~/.rbenv/bin/rbenv version

    # ruby-build-github
    rm -rf ~/.rbenv/plugins/ruby-build-github
    git clone https://github.com/parkr/ruby-build-github.git ~/.rbenv/plugins/ruby-build-github

    # list ruby versions compatible with github pages
    local ruby_v
    ruby_v=$(~/.rbenv/bin/rbenv install --list | grep github$ | tail -1)

    # install ruby
    # export MAKE=make (uncomment if build fails)
    [ $? -eq 0 ] && ~/.rbenv/bin/rbenv install "$ruby_v"
    [ $? -eq 0 ] && ~/.rbenv/bin/rbenv global "$ruby_v"

    # check ruby and rubygem versions
    ~/.rbenv/shims/ruby -v
    ~/.rbenv/shims/gem env home

    RET="$?"
    debug
}

# install the long term support version of Node.js via NVM
qc_install_node() {
    local node_v
    # install NVM
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

    # source nvm
    . ~/.nvm/nvm.sh

    # make sure nvm is installed
    qc_has nvm || error "nvm install failed"

    # get long term support version
    node_v=$(nvm ls-remote | grep "v${LTS}.*" | tail -1 | tr -d ' ')

    # install nodejs
    nvm install "$node_v"

    if [ $? -eq 0 ]; then
        # nvm use "$node_v"
        nvm alias default "$node_v"
        npm build
    fi

    # check which node
    which node
    which npm

    # check node version
    node -v
    npm -v

    notify "After switching node versions, remember to run \`npm build\`."

    RET="$?"
    debug
}

# --------------------------  CHECK FOR MISSING PROGRAMS

# loop through check list and add missing gems to install list
qc_gem_check() {
    local pkg
    local pkg_version

    for pkg in "${gem_check_list[@]}"
    do
        if ~/.rbenv/shims/gem list ^"$pkg"$ -i >/dev/null 2>&1; then
            pkg_version=$(~/.rbenv/shims/gem list ^"$pkg"$ | grep "${pkg}" | cut -d " " -f 2 | cut -d "(" -f 2 | cut -d ")" -f 1)
            print_pkg_info "$pkg" "$pkg_version"
        else
            echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
            gem_install_list+=($pkg)
        fi
    done

    RET="$?"
    debug
}

# loop through check list and add missing npms to install list
qc_npm_check() {
    local pkg
    local pkg_version

    for pkg in "${npm_check_list[@]}"
    do
        if npm ls -gs | grep -q "${pkg}@"; then
            pkg_version=$(npm ls -gs | grep "${pkg}@" | cut -d "@" -f 2)
            print_pkg_info "$pkg" "$pkg_version"
        else
            echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
            npm_install_list+=($pkg)
        fi
    done

    RET="$?"
    debug
}

# loop through check list and add missing pips to install list
qc_pip_check() {
    local pkg
    local pkg_trim
    local pkg_version

    for pkg in "${pip_check_list[@]}"
    do
        pkg_trim=$(trim_longest_right_pattern "$pkg" "[")
        if pip list | grep -w "$pkg_trim" >/dev/null 2>&1; then
            pkg_version=$(pip list | grep -w "${pkg_trim}" | cut -d " " -f 2 | tr -d "(" | tr -d ")")
            print_pkg_info "$pkg" "$pkg_version"
        else
            echo -e " ${YELLOW_BLACK} * $pkg_trim [not installed] ${NONE_WHITE}"
            pip_install_list+=($pkg)
        fi
    done

    RET="$?"
    debug
}

# loop through check list and add missing pip3s to install list
qc_pip3_check() {
    local pkg
    local pkg_trim
    local pkg_version

    for pkg in "${pip3_check_list[@]}"
    do
        pkg_trim=$(trim_longest_right_pattern "$pkg" "[")
        if pip list | grep -w "$pkg_trim" >/dev/null 2>&1; then
            pkg_version=$(pip3 list | grep -w "${pkg_trim}" | cut -d " " -f 2 | tr -d "(" | tr -d ")")
            print_pkg_info "$pkg" "$pkg_version"
        else
            echo -e " ${YELLOW_BLACK} * $pkg_trim [not installed] ${NONE_WHITE}"
            pip3_install_list+=($pkg)
        fi
    done

    RET="$?"
    debug
}

# loop through check list and add missing packages to install list
qc_apt_check() {
    local pkg
    local pkg_version

    for pkg in "${apt_check_list[@]}"
    do
        if not_installed "$pkg"; then
            echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
            apt_install_list+=($pkg)
        else
            pkg_version=$(dpkg -s "${pkg}" 2>&1 | grep 'Version:' | cut -d " " -f 2)
            print_pkg_info "$pkg" "$pkg_version"
        fi
    done

    RET="$?"
    debug
}

# --------------------------  INSTALL MISSING PROGRAMS

# loop through install list and install any gems that are in the list
qc_gem_install() {
    # install ruby with rbenv
    confirm "Install the latest version of ruby with rbenv?" true
    [ $? -eq 0 ] && install_rbenv_ruby

    qc_gem_check

    if [[ "${#gem_install_list[@]}" -eq 0 ]]; then
        notify "No gems to install"
    else
        # install required gems
        pause "Press [Enter] to install gems" true
        # shellcheck disable=SC2068
        ~/.rbenv/shims/gem install ${gem_install_list[@]}
        ~/.rbenv/bin/rbenv rehash
    fi

    RET="$?"
    debug
}

# loop through install list and install any npms that are in the list
qc_npm_install() {
    # make sure npm is installed
    confirm "Install nodejs?" true
    if [ $? -eq 0 ]; then
      msg "Which version to install?"
      select version in "Long Term Support" "Package Manager"; do
        case $version in
          "Long Term Support") qc_install_node
            ;;
          "Package Manager") program_must_exist nodejs
            ;;
          *) echo "case not found"
            ;;
        esac
        break
      done
    fi

    # make sure npm is installed before proceeding
    qc_has npm || { notify3 "warning: nodejs is not installed, skipping npms" && return 0; }

    npm build
    qc_npm_check

    if [[ "${#npm_install_list[@]}" -eq 0 ]]; then
        notify "No npms to install"
    else
        # install required npms
        pause "Press [Enter] to install npms" true
        if qc_has nvm; then
            # shellcheck disable=SC2068
            npm install -g ${npm_install_list[@]}
        else
            # shellcheck disable=SC2068
            sudo npm install -g ${npm_install_list[@]}
        fi
    fi

    RET="$?"
    debug
}

# loop through install list and install any pips that are in the list
qc_pip_install() {
    # make sure dependencies are installed
    program_must_exist "python-pip"
    program_must_exist "python3-pip"
    program_must_exist "python-keyring"
    program_must_exist "python-setuptools"

    qc_pip_check

    if [[ "${#pip_install_list[@]}" -eq 0 ]]; then
        notify "No pips to install"
    else
        # install required pips
        pause "Press [Enter] to install pips" true
        # shellcheck disable=SC2068
        sudo -H pip install ${pip_install_list[@]}
    fi

    RET="$?"
    debug
}

# loop through install list and install any pips that are in the list
qc_pip3_install() {
    # make sure dependencies are installed
    program_must_exist "python3-pip"

    qc_pip3_check

    if [[ "${#pip3_install_list[@]}" -eq 0 ]]; then
        notify "No pip3s to install"
    else
        # install required pips
        pause "Press [Enter] to install pip3s" true
        # shellcheck disable=SC2068
        sudo -H pip3 install ${pip3_install_list[@]}
    fi

    RET="$?"
    debug
}

# loop through install list and install any packages that are in the list
# $1 -> to update sources or not
qc_apt_install() {
    qc_apt_check

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
        # shellcheck disable=SC2068
        sudo apt-get -y install ${apt_install_list[@]}

        # clean up apt caches
        sudo apt-get clean
    fi

    # shellcheck disable=SC2034
    RET="$?"
    debug
}

# --------------------------  64-BIT ARCHITECTURE

UPDATE=0
if [ "$(dpkg --print-foreign-architectures)" = "i386" ]; then
    dpkg --get-selections | grep i386 || notify "no i386 packages installed"
    pause "Press [Enter] to purge all i386 packages and remove the i386 architecture" true
    sudo apt-get purge ".*:i386" && sudo dpkg --remove-architecture i386 && sudo apt-get update && success "Success, goodbye i386!" && UPDATE=1
fi

# --------------------------  DEFAULT APT PACKAGES

DEFAULT_SERVER_LIST='ca-certificates gettext-base less man-db openssh-server python-software-properties software-properites-common vim-gtk wget'
DEFAULT_WORKSTATION_LIST='autojump gpgv2 lynx mutt pinta x11vnc xclip vlc'
DEFAULT_DEV_LIST='autoconf automake build-essential checkinstall dconf-cli shellcheck silversearcher-ag tmux tidy xdotool vim-gtk'

# --------------------------  PROMPT FOR PROGRAMS

if [ "$IS_SERVER" -eq 0 ]; then
    notify "Server packages to install (none to skip)"
    read -ep "   : " -i "$DEFAULT_SERVER_LIST" APTS1
else
    notify3 "The following default packages can be modified prior to installation."
    echo
    echo "GEMs, NPMs, PIPs"
    echo "WORKSTATION"
    echo "DEVELOPER"
    echo
    notify "Packages to install with gem"
    read -ep "   : " -i 'bundler gist travis' GEMS
    notify "Packages to install with npm"
    read -ep "   : " -i 'bower browser-sync coffee-script csslint gulp remark remark-toc svgo' NPMS
    notify "Packages to install with pip"
    read -ep "   : " -i 'jrnl[encrypted] pyflakes python-slugify' PIPS
    # notify "Packages to install with pip3"
    # shellcheck disable=SC2034
    # read -ep "   : " -i 'pep8' PIP3S
    notify "Workstation packages to install (delete all to skip)"
    read -ep "   : " -i "$DEFAULT_WORKSTATION_LIST" APTS1
    notify "Developer packages to install"
    read -ep "   : " -i "$DEFAULT_DEV_LIST" APTS2
fi

# --------------------------  ARRAY ASSIGNMENTS

# add packages, gems, npms and pips to check list arrays
gem_check_list+=($GEMS)
npm_check_list+=($NPMS)
pip_check_list+=($PIPS)
# pip3_check_list+=($PIP3S)
apt_check_list+=($APTS1)
apt_check_list+=($APTS2)

# --------------------------  RESET FUNCTIONS

# unset the various functions defined during execution of the install script
qc_reset() {
  unset -f qc_reset qc_has qc_gem_install qc_npm_install qc_pip_install qc_apt_install \
    qc_gem_check qc_npm_check qc_pip_check qc_apt_check \
    qc_install_node qc_install_rbenv_ruby
}

# --------------------------  INSTALL PROGRAMS

qc_gem_install
qc_npm_install
qc_pip_install
# qc_pip3_install
qc_apt_install "$UPDATE"
qc_reset

} # this ensures the entire script is downloaded #
