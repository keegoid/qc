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
if grep -q $CONFIG/.bash_aliases $HOME/.bashrc >/dev/null 2>&1; then
   echo "already added aliases"
else
   pause "Press [Enter] to add useful aliases" true
   cp -n $PROJECT/includes/.bash_aliases $HOME/$CONFIG
cat << EOF >> $HOME/.bashrc
# source .bash_aliases
if [ -f ~/$CONFIG/.bash_aliases ]; then
    . ~/$CONFIG/.bash_aliases
fi
EOF
   [ -f $HOME/$CONFIG/.bash_aliases ] && source $HOME/.bashrc && echo "successfully configured: .bashrc with .bash_aliases from ~/$CONFIG"
fi

# autojump
if grep -q $CONFIG/.bash_config $HOME/.bashrc >/dev/null 2>&1; then
   echo "already added autojump (usage: j directory)"
else
   pause "Press [Enter] to add autojump to bash" true
   cp -n $PROJECT/includes/.bash_config $HOME/$CONFIG
cat << EOF >> $HOME/.bashrc
# source .bash_config
if [ -f ~/$CONFIG/.bash_config ]; then
   . ~/$CONFIG/.bash_config
fi
EOF
   [ -f $HOME/$CONFIG/.bash_config ] && source $HOME/.bashrc && echo "successfully configured: .bashrc with .bash_config from ~/$CONFIG"
fi

# color terminal prompts
if grep -q "#force_color_prompt=yes" $HOME/.bashrc >/dev/null 2>&1; then
   pause "Press [Enter] to activate color terminal prompts" true
   sed -i.bak -e "s|#force_color_prompt=yes|force_color_prompt=yes|" $HOME/.bashrc && source $HOME/.bashrc && echo "successfully configured: .bashrc with color terminal prompts"
else
   echo "already set color prompts"
fi

# --------------------------------------------
# .inputrc
# --------------------------------------------

# terminal history lookup
if grep -q $CONFIG/.input_config $HOME/.inputrc >/dev/null 2>&1; then
   echo "already added terminal history lookup"
else
   pause "Press [Enter] to configure .inputrc" true
   cp -n $PROJECT/includes/.input_config $HOME/$CONFIG
cat << EOF >> $HOME/.inputrc
\$include ~/$CONFIG/.input_config
EOF
   [ -f $HOME/$CONFIG/.input_config ] && echo ".input_config was copied to ~/$CONFIG"
fi

# --------------------------------------------
# terminal default profile
# --------------------------------------------

# profile directory
DEFAULT=$HOME/.gconf/apps/gnome-terminal/profiles/Default

# default profile
if [ -f $HOME/$CONFIG/%gconf.xml ]; then
   echo "already configured terminal default profile"
else
   cp $PROJECT/includes/%gconf.xml $DEFAULT && echo "successfully configured: gnome-terminal default profile"
fi


# --------------------------------------------
# gedit
# --------------------------------------------

# gedit directory
GEDIT=$HOME/.local/share/gedit/styles

# blackboard color scheme
if [ -d $GEDIT/blackboard ]; then
   cd $GEDIT/blackboard && echo "updating blackboard for gedit..." && git pull && cp $GEDIT/blackboard/blackboard.xml $GEDIT && cd - >/dev/null
else
   git clone https://github.com/afair/dot-gedit.git $GEDIT/blackboard && cp $GEDIT/blackboard/blackboard.xml $GEDIT && echo "successfully installed: Gedit color scheme blackboard"
fi

# --------------------------------------------
# .vimrc
# --------------------------------------------

# .vim directories
AUTOLOAD=$HOME/.vim/autoload
BUNDLE=$HOME/.vim/bundle
COLORS=$HOME/.vim/colors
BACKUP=$HOME/.vim/backup
SWP=$HOME/.vim/swp

# pathogen plugin (for loading other plugins)
if [ -d $AUTOLOAD/pathogen ]; then
   cd $AUTOLOAD/pathogen && echo "updating pathogen..." && git pull && cp $AUTOLOAD/pathogen/autoload/pathogen.vim $AUTOLOAD && cd - >/dev/null
else
   git clone https://github.com/tpope/vim-pathogen.git $AUTOLOAD/pathogen && cp $AUTOLOAD/pathogen/autoload/pathogen.vim $AUTOLOAD && echo "successfully installed: vim plugin pathogen"
fi

# blackboard colorscheme
if [ -d $COLORS/blackboard ]; then
   cd $COLORS/blackboard && echo "updating blackboard for vim..." && git pull && cp $COLORS/blackboard/colors/blackboard.vim $COLORS && cd - >/dev/null
else
   git clone https://github.com/ratazzi/blackboard.vim $COLORS/blackboard && cp $COLORS/blackboard/colors/blackboard.vim $COLORS && echo "successfully installed: vim colorscheme blackboard"
fi

# gundo plugin (for graphical undo tree)
if [ -d $BUNDLE/gundo ]; then
   cd $BUNDLE/gundo && echo "updating gundo..." && git pull && cd - >/dev/null
else
   git clone https://github.com/sjl/gundo.vim.git $BUNDLE/gundo && echo "vim plugin gundo was installed"
fi

# ag plugin (for keyword searching within project directory)
if [ -d $BUNDLE/ag ]; then
   cd $BUNDLE/ag && echo "updating ag..." && git pull && cd - >/dev/null
else
   git clone https://github.com/rking/ag.vim.git $BUNDLE/ag && echo "vim plugin ag was installed"
fi

# ctrlp plugin (for fuzzy file searching)
if [ -d $BUNDLE/ctrlp ]; then
   cd $BUNDLE/ctrlp && echo "updating ctrp..." && git pull && cd - >/dev/null
else
   git clone https://github.com/ctrlpvim/ctrlp.vim.git $BUNDLE/ctrlp && echo "vim plugin ctrlp was installed"
fi

# configure vim (from http://dougblack.io/words/a-good-vimrc.html)
if grep -q $CONFIG/.vim_config $HOME/.vimrc >/dev/null 2>&1; then
   echo "already configured .vimrc"
else
   pause "Press [Enter] to configure .vimrc" true
   cp -n $PROJECT/includes/.vim_config $HOME/$CONFIG
   mkdir -p $BACKUP
   mkdir -p $SWP
cat << EOF >> $HOME/.vimrc
" source config file
:so ~/$CONFIG/.vim_config
EOF
   [ -f $HOME/$CONFIG/.vim_config ] && echo "successfully configured: .vimrc with .vim_config from ~/$CONFIG"
fi

