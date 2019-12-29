#!/bin/bash
# --------------------------------------------
# Install/update Ruby & Rubygems via Rbenv.
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keegan@kmauthorized.com
# License: MIT
#
# Attributions:
# package install functions & lists
# github.com/Varying-Vagrant-Vagrants/VVV/
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  MISSING PROGRAM CHECKS

# install lists (perform install)
gem_install_list=()

# check lists (check if installed)
gem_check_list=()

# --------------------------  CHECK FOR MISSING GEMS

# loop through check list and add missing gems to install list
qc_gem_check() {
  local pkg
  local pkg_version

  for pkg in "${gem_check_list[@]}"
  do
    if ~/.rbenv/shims/gem list ^"$pkg"$ -i >/dev/null 2>&1; then
      pkg_version=$(~/.rbenv/shims/gem list ^"$pkg"$ | grep "${pkg}" | cut -d' ' -f2 | cut -d'(' -f2 | cut -d')' -f1)
      lkm_print_pkg_info "$pkg" "$pkg_version"
    else
      echo -e " ${YELLOW_BLACK} * $pkg [not installed] ${NONE_WHITE}"
      gem_install_list+=($pkg)
    fi
  done

  RET="$?"
  lkm_debug
}

# --------------------------  INSTALL MISSING GEMS

# loop through install list and install any gems that are in the list
qc_gem_install() {
  # clear gem install list
  gem_install_list=()

  # add missing gems to install list
  qc_gem_check

  if [[ "${#gem_install_list[@]}" -eq 0 ]]; then
    lkm_notify "No gems to install"
  else
    # install required gems
    lkm_pause "Press [Enter] to install gems" true

    # shellcheck disable=SC2068
    ~/.rbenv/shims/gem install ${gem_install_list[@]}
    ~/.rbenv/bin/rbenv rehash
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  CUSTOM INSTALL SCRIPTS

# install ruby with rbenv and ruby-build
qc_install_rbenv() {
  # ruby dependencies
  lkm_install_apt "autoconf bison build-essential curl git gnupg2 \
  libcurl4-openssl-dev libffi-dev libreadline-dev libsqlite3-dev libssl-dev \
  libssl1.1 libxml2-dev libxslt1-dev libyaml-dev software-properties-common \
  sqlite3 zlib1g-dev"

  # rbenv
  # shellcheck disable=SC2016
  lkm_set_sourced_config  "https://github.com/rbenv/rbenv.git" \
                          "$HOME/.bashrc" \
                          "$HOME/.rbenv/" \
                          '[[ ":$PATH:" =~ ":$HOME/.rbenv/bin:" ]] || PATH="$HOME/.rbenv/bin:$PATH"'

  # optional, to speed up rbenv
  [ -d "$HOME/.rbenv" ] &&  cd "$HOME/.rbenv" && src/configure && make -C src && cd - >/dev/null

  # add rbenv init - command to .bashrc (for SublimeLinter)
  # shellcheck disable=SC2016
  lkm_set_source_cmd      "$HOME/.bashrc" \
                          'rbenv/shims:' \
                          '[[ ":$PATH:" =~ ":$HOME/.rbenv/shims:" ]] || eval "$(rbenv init -)"'

  # ruby-build
  # shellcheck disable=SC2016
  lkm_set_sourced_config  "https://github.com/rbenv/ruby-build.git" \
                          "$HOME/.bashrc" \
                          "$HOME/.rbenv/plugins/ruby-build/" \
                          '[[ ":$PATH:" =~ ":$HOME/.rbenv/plugins/ruby-build/bin:" ]] || PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"'

  # tell rubygems not to install docs for each package locally
  lkm_set_source_cmd      "$HOME/.gemrc" \
                          'no-rdoc' \
                          'gem: --no-ri --no-rdoc'

  lkm_has ~/.rbenv/bin/rbenv || { lkm_error "rbenv install failed"; return 1; }
  ~/.rbenv/bin/rbenv version

  RET="$?"
  lkm_debug
}

qc_install_ruby() {
  # ruby versions
  local ruby_global_v
  local ruby_local_v

  # export MAKE=make

  # install the latest stable ruby version
  ruby_global_v=$(~/.rbenv/bin/rbenv install --list | tr -d ' ' | grep "^\w.\w.\w$" | tail -1)
  [ $? -eq 0 ] && ~/.rbenv/bin/rbenv install "$ruby_global_v"

  # set global ruby version
  ~/.rbenv/bin/rbenv global "$ruby_global_v"

  # check ruby and rubygem versions
  ~/.rbenv/shims/ruby -v
  ~/.rbenv/shims/gem env home

  qc_gem_install

  # install the latest github pages compatible ruby version
  # rm -rf ~/.rbenv/plugins/ruby-build-github
  # git clone https://github.com/parkr/ruby-build-github.git ~/.rbenv/plugins/ruby-build-github
  # ruby_local_v=$(~/.rbenv/bin/rbenv install --list | grep github$ | tail -n 1 | tr -d ' ')
  # [ $? -eq 0 ] && ~/.rbenv/bin/rbenv install "$ruby_local_v"

  # set global ruby version
  # ~/.rbenv/bin/rbenv global "$ruby_local_v"

  # check ruby and rubygem versions
  # ~/.rbenv/shims/ruby -v
  # ~/.rbenv/shims/gem env home

  # qc_gem_install

  # set global ruby version
  # ~/.rbenv/bin/rbenv global "$ruby_global_v"

  # shellcheck disable=SC2034
  RET="$?"
  lkm_debug
}

# --------------------------  PROMPT FOR PROGRAMS

echo
echo "Rubygems"
echo
lkm_notify "Packages to install with gem"
read -rep "   : " -i 'bundler gist travis' GEMS

# --------------------------  ARRAY ASSIGNMENTS

# add gems to check
gem_check_list+=($GEMS)

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the install script
qc_reset() {
  unset -f qc_reset qc_gem_check qc_gem_install qc_install_rbenv qc_install_ruby
}

# --------------------------  INSTALL PROGRAMS

# install rbenv
lkm_confirm "Install rbenv?" true
[ $? -eq 0 ] && qc_install_rbenv

# install ruby with rbenv
lkm_confirm "Install ruby via rbenv?" true
[ $? -eq 0 ] && qc_install_ruby

qc_reset

} # this ensures the entire script is downloaded #
