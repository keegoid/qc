#!/bin/bash
# --------------------------------------------
# Configure some terminal settings.
#
# Author : Keegan Mullaney
# Website: keegoid.com
# Email  : keeganmullaney@gmail.com
# License: keegoid.mit-license.org
# --------------------------------------------

{ # this ensures the entire script is downloaded #

# --------------------------  SETUP PARAMETERS

[ -z "$QC_CONFIG" ] && QC_CONFIG="$HOME/.qc"
[ -z "$QC_BACKUP" ] && QC_BACKUP="$QC_CONFIG/backup"
[ -z "$QC_SYNCED" ] && read -ep "Directory to store/sync your config: " -i "$HOME/Dropbox/config" QC_SYNCED

# system and program config files
CONF1="$HOME/.bashrc"
CONF2="$HOME/.inputrc"
CONF3="$QC_SYNCED/sublime/User/Preferences.sublime-settings"
CONF5="$HOME/.muttrc"
CONF6="$HOME/.vimrc"
CONF7="$HOME/.gitignore_global"

# config files copied from repositories
REPO1="/usr/share/autojump/autojump.sh"
REPO3=$HOME/.config/sublime-text-3/Packages/Theme - KMS/subl.conf"
REPO5="$QC_CONFIG/mutt/colors/mutt-colors-solarized-dark-16.muttrc"
REPO6="$QC_CONFIG/vim/vim.conf"
REPO7="$QC_CONFIG/git/gitignore_global"

# --------------------------  BACKUPS

# backup config files
qc_do_backup() {
  local name
  local today

  lkm_confirm "Backup config files before making changes?" true
  [ $? -gt 0 ] && return 1

  today=$(date +%Y%m%d_%s)
  mkdir -pv "$QC_BACKUP-$today"

  for i in $1
  do
    if [ -e "$i" ] && [ ! -L "$i" ]; then
      name=$(lkm_trim_longest_left_pattern "$i" "/")
      cp "$i" "$QC_BACKUP-$today/$name" && lkm_success "made backup: $QC_BACKUP-$today/$name"
    fi
  done

  RET="$?"
  lkm_debug

  return 0
}

# --------------------------  SUBL CONFIG

# clone or pull git repo and copy repo files into proper places
qc_set_subl_config() {
  local repo_url="$1"
  local conf_file="$CONF3"
  local repo_file="$REPO3"
  local repo_dir
  local repo_name
  local cloned=1
  local user_dir="$HOME/.config/sublime-text-3/Packages/User"

  repo_dir=$(lkm_trim_shortest_right_pattern "$REPO3" "/")
  repo_name=$(lkm_trim_longest_left_pattern "$repo_dir" "/")

  # check if standard directory exists and if so, make a backup and remove it
  [ -d "$user_dir" ] && { mv "$user_dir" "${user_dir}-bak"; rm -r "$user_dir"; }

  # make sure directories exist
  mkdir -p "$HOME/.config/sublime-text-3/Packages"
  mkdir -p "$QC_SYNCED/sublime/User"

  # symlink to User directory in Dropbox
  ln -s "$QC_SYNCED/sublime/User" "$user_dir"

  # update or clone repository
  if [ -d "$repo_dir" ]; then
    (
      cd "$repo_dir" || exit
      echo "checking for updates: $repo_name"
      git pull
    )
  else
    git clone "$repo_url" "$repo_dir" && cloned=0
  fi

  # copy config file to proper location
  cp "$repo_file" "$conf_file"
  if [ $? -eq 0 ] && [ "$cloned" -eq 0 ]; then
    lkm_success "configured: $conf_file"
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  GIT CONFIG

# clone or pull git repo and copy repo file onto conf file
qc_set_git_config() {
  local repo_url="$1"
  local conf_file="$CONF7"
  local repo_file="$REPO7"
  local repo_dir
  local repo_name
  local cloned=1

  repo_dir=$(lkm_trim_shortest_right_pattern "$REPO7" "/")
  repo_name=$(lkm_trim_longest_left_pattern "$repo_dir" "/")

  # update or clone repository
  if [ -d "$repo_dir" ]; then
    (
      cd "$repo_dir" || exit
      echo "checking for updates: $repo_name"
      git pull
    )
  else
    git clone "$repo_url" "$repo_dir" && cloned=0
  fi

  # copy config file to proper location
  cp "$repo_file" "$conf_file"
  if [ $? -eq 0 ] && [ "$cloned" -eq 0 ]; then
    lkm_success "configured: $conf_file"
  fi

  # check if git is already configured
  if ! git config --list | grep -q "user.name"; then
    read -ep "your name for git commit logs: " -i 'Keegan Mullaney' real_name
    read -ep "your email for git commit logs: " -i 'keeganmullaney@gmail.com' email_address
    read -ep "your preferred text editor for git commits: " -i 'vi' git_editor
    lkm_configure_git "$real_name" "$email_address" "$git_editor" && lkm_success "configured: $CONF7"
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  TERMINAL HISTORY LOOKUP (also awesome)

qc_set_terminal_history() {
  local conf_file="$1"

  [ -f "$conf_file" ] || touch "$conf_file"
  if grep -q "backward-char" "$conf_file" >/dev/null 2>&1; then
    echo "already added terminal history lookup (usage: start of command + up arrow)"
  else
    lkm_pause "Press [Enter] to configure .inputrc" true
cat << 'EOF' >> "$conf_file"
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char
EOF
    lkm_success "configured: $conf_file (usage: start of command + up arrow)"
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  TERMINAL COLOR PROMPTS

qc_set_terminal_color() {
  local conf_file="$1"

  if grep -q "#force_color_prompt=yes" "$conf_file" >/dev/null 2>&1; then
    lkm_pause "Press [Enter] to activate color terminal prompts" true
    sed -i.bak -e "/force_color_prompt=yes/ s/^# //" "$conf_file" && source "$conf_file" && lkm_success "configured: $conf_file with color terminal prompts"
  else
    echo "already set color prompts"
  fi

  RET="$?"
  lkm_debug
}

# --------------------------  AUTOJUMP (so awesome)

qc_set_autojump() {
  local conf_file="$1"
  local src_cmd="$2"

  if grep -q "autojump/autojump.sh" "$conf_file" >/dev/null 2>&1; then
    echo "already added autojump (usage: j directory)"
  else
    lkm_pause "Press [Enter] to configure autojump for gnome-terminal" true
    echo -e "$src_cmd" >> "$conf_file" && source "$conf_file" && lkm_success "configured: $conf_file with autojump (usage: j directory)"
  fi

  # shellcheck disable=SC2034
  RET="$?"
  lkm_debug
}

# --------------------------  UNSET FUNCTIONS

# unset the various functions defined during execution of the script
qc_reset() {
  unset -f qc_reset qc_do_backup qc_set_subl_config qc_set_git_config qc_set_terminal_history qc_set_autojump
}

# --------------------------  MAIN

lkm_pause "" true

qc_do_backup            "$CONF1 $CONF2 $CONF3 $CONF5 $CONF6 $CONF7"

# aliases (to practice terminal commands for Linux certification exams, I'm not using aliases at the moment)
#lkm_set_sourced_config  "https://gist.github.com/9d74e08779c1db6cb7b7" \
#                        "$HOME/.bashrc" \
#                        "$QC_CONFIG/bash/aliases/bash_aliases" \
#                        "\n# source alias file\nif [ -f $QC_CONFIG/bash/aliases/bash_aliases ]; then\n   . $QC_CONFIG/bash/aliases/bash_aliases\nfi"

# mutt config
lkm_set_sourced_config  "https://github.com/altercation/mutt-colors-solarized.git" \
                        "$CONF5" \
                        "$REPO5" \
                        "# source colorscheme file\nsource $REPO5\n\n# signature and alias files\nset signature=$QC_SYNCED/mutt/sig\nset alias_file=$QC_SYNCED/mutt/aliases\n\n# aliases are stored in their own file\nsource \"\$alias_file\""

# vim config
lkm_set_sourced_config  "https://gist.github.com/00a60c7355c27c692262.git" \
                        "$CONF6" \
                        "$REPO6" \
                        "\" source config file\n:so $REPO6\n\nset spellfile=$QC_SYNCED/vim/vim.utf-8.add\t\" spell check file to sync with other computers"

[ -d "$QC_SYNCED/vim" ] || { mkdir -pv "$QC_SYNCED/vim"; lkm_notify3 "note: vim spellfile will be located in $QC_SYNCED/vim, you can change this in $CONF6"; }

# terminal profile (can't find profile file in new Ubuntu 16.04)
#set_copied_config       "https://gist.github.com/dad1663d2463db32c6e8.git" \
#                        "$HOME/.gconf/apps/gnome-terminal/profiles/Default/%gconf.xml" \
#                        "$QC_CONFIG/terminal/profile/gconf.xml"

# sublime text
qc_set_subl_config      "https://github.com/keegoid/kms-theme.git"

qc_set_git_config       "https://gist.github.com/efa547b362910ac7077c.git"

qc_set_terminal_history "$CONF2"

# already done in Ubuntu 16.04
#qc_set_terminal_color   "$CONF1"

qc_set_autojump         "$CONF1" \
                        "\n# source autojump file\nif [ -f $REPO1 ]; then\n   . $REPO1\nfi"

qc_reset

} # this ensures the entire script is downloaded #
