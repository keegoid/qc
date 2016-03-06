#!/bin/bash
echo "# --------------------------------------------"
echo "# Configure some terminal settings.           "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

[ -z "$CONFIG" ] && CONFIG="$HOME/.uqc"
[ -z "$BACKUP" ] && BACKUP="$CONFIG/backup"

# --------------------------  BACKUPS

do_backup() {
   local name

   confirm "Backup config files before making changes?" false
   [ "$?" -gt 0 ] && return 1
   if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ] || [ -e "$4" ] || [ -e "$5" ] || [ -e "$6" ] || [ -e "$7" ] || [ -e "$8" ] || [ -e "$9" ]; then
      today=`date +%Y%m%d_%s`
      [ -d "$BACKUP-$today" ] || mkdir -pv "$BACKUP-$today"
      for i in "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; do
         name=$(trim_longest_left_pattern "$i" "/")
         [ -e "$i" ] && [ ! -L "$i" ] && cp "$i" "$BACKUP-$today/$name" && success "made backup: ~/.uqc/backup-$today/$name";
      done
      RET="$?"
      debug
  fi
  return 0
}

# --------------------------  ALIASES, MUTT, TMUX & VIM

set_sourced_config() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"
   local src_cmd="$4"

   if grep -q "$repo_file_path" "$conf_file_path" >/dev/null 2>&1; then
      notify "already set $repo_file_path in $conf_file_path"
      cd $repo_dir && echo "checking for updates: $repo_file_path" && git pull && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && echo -e "$src_cmd" >> $conf_file_path && success "configured: $conf_file_path"
   fi
}

# --------------------------  GEDIT COLORS, TERMINAL PROFILE, GIT IGNORE

set_copied_config() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"

   if [ -f $repo_file_path ] && [ -f $conf_file_path ]; then
      notify "already set $repo_file_path in $conf_file_path"
      cd $repo_dir && echo "checking for updates: $repo_file_path" && git pull && cp $repo_file_path $conf_file_path && success "updated: $conf_file_path" && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && cp $repo_file_path $conf_file_path && success "configured: $conf_file_path"
   fi
   RET="$?"
}

# --------------------------  GIT CONFIG

set_git_config() {
   local conf_file_path="$1"

   if [ "$RET" -eq 0 ]; then
      read -ep "your name for git commit logs: " -i 'Keegan Mullaney' real_name
      read -ep "your email for git commit logs: " -i 'keeganmullaney@gmail.com' email_address
      read -ep "your preferred text editor for git commits: " -i 'vi' git_editor
      configure_git "$real_name" "$email_address" "$git_editor"
      RET="$?"
      success "configured: $conf_file_path"
   fi
}

# --------------------------  TERMINAL HISTORY LOOKUP (also awesome)

set_terminal_history() {
   local conf_file_path="$1"

   [ -f $conf_file_path ] || touch $conf_file_path
   if grep -q "backward-char" $conf_file_path >/dev/null 2>&1; then
      notify "already added terminal history lookup"
   else
      pause "Press [Enter] to configure .inputrc" true
cat << 'EOF' >> $conf_file_path 
# terminal history lookup
'\e[A': history-search-backward
'\e[B': history-search-forward
'\e[C': forward-char
'\e[D': backward-char
EOF
      REF="$?"
      success "configured: $conf_file_path"
   fi
}

# --------------------------  TERMINAL COLOR PROMPTS

set_terminal_color() {
   local conf_file_path="$1"

   if grep -q "#force_color_prompt=yes" $conf_file_path >/dev/null 2>&1; then
      pause "Press [Enter] to activate color terminal prompts" true
      sed -i.bak -e "s|#force_color_prompt=yes|force_color_prompt=yes|" $conf_file_path && source $conf_file_path && success "configured: $conf_file_path with color terminal prompts"
   else
      notify "already set color prompts"
   fi
}

# --------------------------  AUTOJUMP (so awesome)

set_autojump() {
   local conf_file_path="$1"
   local src_cmd="$2"

   if grep -q "autojump/autojump.sh" $conf_file_path >/dev/null 2>&1; then
      notify "already added autojump (usage: j directory)"
   else
      pause "Press [Enter] to configure autojump for gnome-terminal" true
      echo -e "$src_cmd" >> $conf_file_path && source $conf_file_path && success "configured: $conf_file_path with autojump"
   fi
}

# --------------------------  MAIN

do_backup            "$HOME/.bashrc" \
                     "$HOME/.inputrc" \
                     "$HOME/.gconf/apps/gnome-terminal/profiles/Default/%gconf.xml" \
                     "$HOME/.local/share/gedit/styles/blackboard.xml" \
                     "$HOME/.local/share/gedit/styles/solarized-dark.xml" \
                     "$HOME/.muttrc" \
                     "$HOME/.tmux.conf" \
                     "$HOME/.vimrc.local" \
                     "$HOME/.gitignore_global"

# aliases
set_sourced_config   "$HOME/.bashrc" \
                     "https://gist.github.com/9d74e08779c1db6cb7b7" \
                     "$CONFIG/bash/aliases/bash_aliases" \
                     "\n# source alias file\nif [ -f $CONFIG/bash/aliases/bash_aliases ]; then\n   . $CONFIG/bash/aliases/bash_aliases\nfi"

# mutt color scheme
set_sourced_config   "$HOME/.muttrc" \
                     "https://github.com/altercation/mutt-colors-solarized.git" \
                     "$CONFIG/mutt/colors/mutt-colors-solarized-dark-16.muttrc" \
                     "# source colorscheme file\nsource $CONFIG/mutt/colors/mutt-colors-solarized-dark-16.muttrc"

# tmux config
set_sourced_config   "$HOME/.tmux.conf" \
                     "https://gist.github.com/3247d5a1c172167e593c.git" \
                     "$CONFIG/tmux/tmux.conf" \
                     "source-file $CONFIG/tmux/tmux.conf"

# vim config
set_sourced_config   "$HOME/.vimrc.local" \
                     "https://gist.github.com/00a60c7355c27c692262.git" \
                     "$CONFIG/vim/vim.conf" \
                     "\" source config file\n:so $CONFIG/vim/vim.conf"

# terminal profile
set_copied_config    "$HOME/.gconf/apps/gnome-terminal/profiles/Default/%gconf.xml" \
                     "https://gist.github.com/dad1663d2463db32c6e8.git" \
                     "$CONFIG/terminal/profile/gconf.xml"

# gedit color scheme
set_copied_config    "$HOME/.local/share/gedit/styles/blackboard.xml" \
                     "https://github.com/afair/dot-gedit.git" \
                     "$CONFIG/gedit/blackboard/blackboard.xml"

# gedit color scheme
set_copied_config    "$HOME/.local/share/gedit/styles/solarized-dark.xml" \
                     "https://github.com/mattcan/solarized-gedit.git" \
                     "$CONFIG/gedit/solarized/solarized-dark.xml"

# gedit color scheme
set_copied_config    "$HOME/.local/share/gedit/styles/solarized-light.xml" \
                     "https://github.com/mattcan/solarized-gedit.git" \
                     "$CONFIG/gedit/solarized/solarized-light.xml"

set_copied_config    "$HOME/.gitignore_global" \
                     "https://gist.github.com/efa547b362910ac7077c.git" \
                     "$CONFIG/git/gitignore_global"

set_git_config       "$HOME/.gitconfig" \

set_terminal_history "$HOME/.inputrc"

set_terminal_color   "$HOME/.bashrc"

set_autojump         "$HOME/.bashrc" \
                     "\n# source autojump file\nif [ -f /usr/share/autojump/autojump.sh ]; then\n   . /usr/share/autojump/autojump.sh\nfi"

[ "$?" -eq 0 ] && source "$HOME/.bashrc"

