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

read -ep "Directory to use for config files: ~/" -i "Dropbox/Config" CONFIG

# --------------------------------------------
# .bashrc
# --------------------------------------------

# aliases
REPO_DIR="$HOME/$CONFIG/bash"
REPO_URL=https://gist.github.com/9d74e08779c1db6cb7b7
CONF_PATH=$HOME/.bashrc
REPO_PATH=$REPO_DIR/bash_aliases
REPO_FILE=$(trim_longest_left_pattern $REPO_PATH "/")
SRC_CMD="\n# source $REPO_FILE\n
if [ -f $REPO_PATH ]; then\n
    . $REPO_PATH\n
fi"

# if config file exists, update config, otherwise clone it
if [ -f $REPO_PATH ]; then
   cd $REPO_DIR && echo "updating $REPO_FILE..." && git pull && echo "successfully updated: $REPO_PATH" && cd - >/dev/null
else
   pause "Press [Enter] to configure $CONF_PATH" true
   git clone $REPO_URL $REPO_DIR && echo -e "$SRC_CMD" >> $CONF_PATH && source $CONF_PATH && echo "successfully configured: $CONF_PATH"
fi

# autojump
SRC_CMD="\n# source autojump.sh\n
. /usr/share/autojump/autojump.sh"

if grep -q "autojump/autojump.sh" $CONF_PATH >/dev/null 2>&1; then
   echo "already added autojump (usage: j directory)"
else
   pause "Press [Enter] to configure autojump for the gnome-terminal" true
   echo -e "$SRC_CMD" >> $CONF_PATH && source $CONF_PATH && echo "successfully configured: $CONF_PATH"
fi

# color terminal prompts
if grep -q "#force_color_prompt=yes" $CONF_PATH >/dev/null 2>&1; then
   pause "Press [Enter] to activate color terminal prompts" true
   sed -i.bak -e "s|#force_color_prompt=yes|force_color_prompt=yes|" $CONF_PATH && source $CONF_PATH && echo "successfully configured: $CONF_PATH with color terminal prompts"
else
   echo "already set color prompts"
fi

# --------------------------------------------
# .inputrc
# --------------------------------------------

# terminal history lookup
CONF_PATH=$HOME/.inputrc
SRC_CMD="# terminal history lookup\n
'\e[A': history-search-backward\n
'\e[B': history-search-forward\n
'\e[C': forward-char\n
'\e[D': backward-char"

if grep -q $CONFIG/.input_config $CONF_PATH >/dev/null 2>&1; then
   echo "already added terminal history lookup"
else
   pause "Press [Enter] to configure .inputrc" true
   echo -e "$SRC_CMD" > $CONF_PATH && source $CONF_PATH && echo "successfully configured: $CONF_PATH"
fi

# --------------------------------------------
# .muttrc solarized colorscheme
# --------------------------------------------

REPO_DIR=$HOME/$CONFIG/mutt/mutt-colors-solarized
REPO_URL=https://github.com/altercation/mutt-colors-solarized.git
REPO_PATH=$REPO_DIR/mutt-colors-solarized-dark-16.muttrc
CONF_PATH=$HOME/$CONFIG/mutt/mutt.conf
COLOR_FILE=$(trim_longest_left_pattern $REPO_DIR "/")

# if config file exists, update config, otherwise clone it
if [ -d $REPO_DIR ]; then
   cd $REPO_DIR && echo "updating $COLOR_FILE..." && git pull && echo "successfully updated: $COLOR_FILE" && cd - >/dev/null
else
   pause "Press [Enter] to configure $COLOR_FILE" true
   git clone $REPO_URL $REPO_DIR && echo "successfully configured: $COLOR_FILE"
fi

# --------------------------------------------
# terminal solarized profile
# --------------------------------------------

REPO_DIR=$HOME/$CONFIG/terminal
REPO_URL=https://github.com/Anthony25/gnome-terminal-colors-solarized.git
REPO_PATH=$REPO_DIR/install.sh

# if config directory exists, update config, otherwise clone it
if [ -d $REPO_DIR ]; then
   cd $REPO_DIR && echo "updating gnome-terminal solarized profile..." && git pull && run_script install.sh && echo "successfully updated: gnome-terminal with solarized colors" && cd - >/dev/null
else
   pause "Press [Enter] to configure gnome-terminal solarized profile" true
   git clone $REPO_URL $REPO_DIR && run_script install.sh && echo "successfully configured: gnome-terminal with solarized colors"
fi

# --------------------------------------------
# .tmux.conf
# --------------------------------------------

REPO_DIR=$HOME/$CONFIG/tmux
REPO_URL=https://gist.github.com/3247d5a1c172167e593c.git
CONF_PATH=$HOME/.tmux.conf
REPO_PATH=$REPO_DIR/tmux.conf
CONF_FILE=$(trim_longest_left_pattern $CONF_PATH "/")

# if config directory exists, update config, otherwise clone it
if [ -d $REPO_DIR ]; then
   cd $REPO_DIR && echo "updating $CONF_FILE..." && git pull && echo "successfully updated: $CONF_PATH" && cd - >/dev/null
else
   pause "Press [Enter] to configure $CONF_FILE" true
   git clone $REPO_URL $REPO_DIR && echo "source-file $REPO_PATH" > $CONF_PATH && echo "successfully configured: $CONF_PATH"
fi

# --------------------------------------------
# gedit
# --------------------------------------------

REPO_DIR=$HOME/$CONFIG/gedit/blackboard
REPO_URL=https://github.com/afair/dot-gedit.git
CONF_PATH=$HOME/.local/share/gedit/styles/blackboard.xml
REPO_PATH=$REPO_DIR/blackboard.xml
CONF_FILE=$(trim_longest_left_pattern $CONF_PATH "/")

# if config directory exists, update config, otherwise clone it
if [ -d $REPO_DIR ]; then
   cd $REPO_DIR && echo "updating $CONF_FILE..." && git pull && cp $REPO_PATH $CONF_PATH && echo "successfully updated: $CONF_PATH" && cd - >/dev/null
else
   pause "Press [Enter] to configure $CONF_FILE" true
   git clone $REPO_URL $REPO_DIR && cp $REPO_PATH $CONF_PATH && echo "successfully configured: $CONF_PATH"
fi

# --------------------------------------------
# .vimrc.local for use with spf13-vim
# --------------------------------------------

REPO_DIR=$HOME/$CONFIG/vim
REPO_URL=https://gist.github.com/00a60c7355c27c692262
CONF_PATH=$HOME/.vimrc.local
REPO_PATH=$REPO_DIR/vim.conf
CONF_FILE=$(trim_longest_left_pattern $CONF_PATH "/")

# check if vim is already configured
if [ -d $REPO_DIR ]; then
   cd $REPO_DIR && echo "updating $CONF_FILE..." && git pull && echo "successfully updated: $CONF_PATH" && cd - >/dev/null
else
   pause "Press [Enter] to configure $CONF_FILE" true
   git clone $REPO_URL $REPO_DIR && echo ":so $REPO_PATH" > $CONF_PATH && echo "successfully configured: $CONF_PATH"
fi

