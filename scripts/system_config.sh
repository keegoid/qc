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

read -ep "Directory to use for config files: ~/" -i "Dropbox/Config" CONFIG

# --------------------------  ALIASES

set_aliases() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"
   local src_cmd="$4"

   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && echo -e "$src_cmd" >> $conf_file_path && source $conf_file_path && success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  TERMINAL COLOR PROMPTS

set_terminal_color() {
   local conf_file_path="$1"

   if grep -q "#force_color_prompt=yes" $conf_file_path >/dev/null 2>&1; then
      pause "Press [Enter] to activate color terminal prompts" true
      sed -i.bak -e "s|#force_color_prompt=yes|force_color_prompt=yes|" $conf_file_path && source $conf_file_path && success "successfully configured: $conf_file_path with color terminal prompts"
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
      echo -e "$src_cmd" >> $conf_file_path && source $conf_file_path && success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  TERMINAL HISTORY LOOKUP (also awesome)

set_terminal_history() {
   local conf_file_path="$1"
   local conf_cmd="$2"

   if grep -q "backward-char" $conf_file_path >/dev/null 2>&1; then
      notify "already added terminal history lookup"
   else
      pause "Press [Enter] to configure .inputrc" true
cat << 'EOF' > $conf_file_path 
# terminal history lookup
'\e[A': history-search-backward
'\e[B': history-search-forward
'\e[C': forward-char
'\e[D': backward-char
EOF
   fi

   REF=$?
   success "successfully configured: $conf_file_path"
}

# --------------------------  TERMINAL PROFILE

set_terminal_profile() {
   local repo_url="$1"
   local repo_dir=$(trim_shortest_right_pattern "$2" "/")
   local repo_file_path="$2"

   # solarized color scheme
   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && { run_script install.sh; RET=$?; success "successfully updated: gnome-terminal profile"; } && cd - >/dev/null
   else
      pause "Press [Enter] to run $repo_file_path" true
      git clone $repo_url $repo_dir && run_script install.sh && success "successfully configured: gnome-terminal with solarized colors"
   fi
}

# --------------------------  GEDIT

set_gedit_colors() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"

   # solarized and blackboard color schemes
   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && cp $repo_file_path $conf_file_path && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && cp $repo_file_path $conf_file_path && success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  MUTT

set_mutt_colors() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"
   local src_cmd="$4"

   # solarized color scheme
   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && echo -e "$src_cmd" >> $conf_file_path && success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  TMUX

set_tmux_config() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"
   local src_cmd="$4"

   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && echo "$src_cmd" > $conf_file_path && success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  VIM

set_vim_config() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"
   local src_cmd="$4"

   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && echo -e "$src_cmd" > $conf_file_path && success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  GIT

set_git_ignore() {
   local conf_file_path="$1"
   local repo_url="$2"
   local repo_dir=$(trim_shortest_right_pattern "$3" "/")
   local repo_file_path="$3"

   # global ignore
   if [ -f $repo_file_path ]; then
      pause "Press [Enter] to update $repo_file_path" true
      cd $repo_dir && echo "updating $repo_file_path..." && git pull && cp $repo_file_path $conf_file_path && cd - >/dev/null
   else
      pause "Press [Enter] to configure $conf_file_path" true
      git clone $repo_url $repo_dir && cp $repo_file_path $conf_file_path
      read -ep "your name for git commit logs: " -i 'Keegan Mullaney' real_name
      read -ep "your email for git commit logs: " -i 'keeganmullaney@gmail.com' email_address
      read -ep "your preferred text editor for git commits: " -i 'vi' git_editor
      configure_git "$real_name" "$email_address" "$git_editor"
      RET=$?
      success "successfully configured: $conf_file_path"
   fi
}

# --------------------------  MAIN

set_aliases          "$HOME/.bashrc" \
                     "https://gist.github.com/9d74e08779c1db6cb7b7" \
                     "$HOME/$CONFIG/bash/aliases/bash_aliases" \
                     "\n# source alias file\nif [ -f ~/$CONFIG/bash/aliases/bash_aliases ]; then\n   . ~/$CONFIG/bash/aliases/bash_aliases\nfi"

set_terminal_color   "$HOME/.bashrc"

set_autojump         "$HOME/.bashrc" \
                     "\n# source autojump file\nif [ -f /usr/share/autojump/autojump.sh ]; then\n   . /usr/share/autojump/autojump.sh\nfi"

set_terminal_history "$HOME/.inputrc"

set_terminal_profile "https://github.com/Anthony25/gnome-terminal-colors-solarized.git" \
                     "$HOME/$CONFIG/terminal/profile/install.sh"

set_gedit_colors     "$HOME/.local/share/gedit/styles/blackboard.xml" \
                     "https://github.com/afair/dot-gedit.git" \
                     "$HOME/$CONFIG/gedit/blackboard/blackboard.xml"

set_gedit_colors     "$HOME/.local/share/gedit/styles/solarized-dark.xml" \
                     "https://github.com/mattcan/solarized-gedit.git" \
                     "$HOME/$CONFIG/gedit/solarized/solarized-dark.xml"

set_mutt_colors      "$HOME/.muttrc" \
                     "https://github.com/altercation/mutt-colors-solarized.git" \
                     "$HOME/$CONFIG/mutt/colors/mutt-colors-solarized-dark-16.muttrc" \
                     "# source colorscheme file\nsource ~/$CONFIG/mutt/colors/mutt-colors-solarized-dark-16.muttrc"

set_tmux_config      "$HOME/.tmux.conf" \
                     "https://gist.github.com/3247d5a1c172167e593c.git" \
                     "$HOME/$CONFIG/tmux/tmux.conf" \
                     "source-file ~/$CONFIG/tmux/tmux.conf"

set_vim_config       "$HOME/.vimrc.local" \
                     "https://gist.github.com/00a60c7355c27c692262.git" \
                     "$HOME/$CONFIG/vim/vim.conf" \
                     "\" source config file\n:so ~/$CONFIG/vim/vim.conf"

set_git_ignore       "$HOME/.gitignore_global" \
                     "https://gist.github.com/efa547b362910ac7077c.git" \
                     "$HOME/$CONFIG/git/gitignore_global"
