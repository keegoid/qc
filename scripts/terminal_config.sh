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
if grep -q "$CONFIG/.bash_aliases" $HOME/.bashrc >/dev/null 2>&1; then
   echo "already added aliases"
else
   pause "Press [Enter] to add useful aliases" true
   cp -n "$PROJECT/includes/.bash_aliases" "$HOME/$CONFIG"
cat << EOF >> "$HOME/.bashrc"
# source .bash_aliases
if [ -f ~/$CONFIG/.bash_aliases ]; then
    . ~/$CONFIG/.bash_aliases
fi
EOF
   [ -f "$HOME/$CONFIG/.bash_aliases" ] && source "$HOME/.bashrc" && echo ".bash_aliases was copied to ~/$CONFIG and sourced"
fi

# autojump
if grep -q "$CONFIG/.bash_config" $HOME/.bashrc >/dev/null 2>&1; then
   echo "already added autojump (usage: j directory)"
else
   pause "Press [Enter] to add autojump to bash" true
   cp -n "$PROJECT/includes/.bash_config" "$HOME/$CONFIG"
cat << EOF >> "$HOME/.bashrc"
# source .bash_config
if [ -f ~/$CONFIG/.bash_config ]; then
   . ~/$CONFIG/.bash_config
fi
EOF
   [ -f "$HOME/$CONFIG/.bash_config" ] && source "$HOME/.bashrc" && echo ".bash_config was copied to ~/$CONFIG and sourced"
fi

# color terminal prompts
if grep -q "#force_color_prompt=yes" $HOME/.bashrc; then
   pause "Press [Enter] to activate color terminal prompts" true
   sed -i.bak -e "s|#force_color_prompt=yes|force_color_prompt=yes|" $HOME/.bashrc
else
   echo "already set color prompts"
fi

# --------------------------------------------
# .inputrc
# --------------------------------------------

# terminal history lookup
if grep -q "$CONFIG/.input_config" $HOME/.inputrc >/dev/null 2>&1; then
   echo "already added terminal history lookup"
else
   pause "Press [Enter] to configure .inputrc" true
   cp -n "$PROJECT/includes/.input_config" "$HOME/$CONFIG"
cat << EOF >> "$HOME/.inputrc"
\$include ~/$CONFIG/.input_config
EOF
   [ -f "$HOME/$CONFIG/.input_config" ] && echo ".input_config was copied to ~/$CONFIG"
fi

# --------------------------------------------
# .vimrc
# --------------------------------------------

# install vim plugins and colorthemes
[ -d "$HOME/.vim/autoload/pathogen" ] || git clone https://github.com/tpope/vim-pathogen.git $HOME/.vim/autoload/pathogen && cp -n $HOME/.vim/autoload/pathogen/autoload/pathogen.vim $HOME/.vim/autoload && echo "vim plugin pathogen was installed"
[ -f "$HOME/.vim/colors/blackboard.vim" ] || mkdir "$HOME/.vim/colors" && cp -n "$PROJECT/includes/blackboard.vim" "$HOME/.vim/colors/" && echo "vim colortheme blackboard was installed"
[ -d "$HOME/.vim/bundle/gundo" ] || git clone https://github.com/sjl/gundo.vim.git $HOME/.vim/bundle/gundo && echo "vim plugin gundo was installed"
[ -d "$HOME/.vim/bundle/ag" ] || git clone https://github.com/rking/ag.vim.git $HOME/.vim/bundle/ag && echo "vim plugin ag was installed"
[ -d "$HOME/.vim/bundle/ctrlp" ] || git clone https://github.com/ctrlpvim/ctrlp.vim.git $HOME/.vim/bundle/ctrlp && echo "vim plugin ctrlp was installed"

# configure vim (from http://dougblack.io/words/a-good-vimrc.html)
if grep -q ":so ~/$CONFIG/.vim_config" $HOME/.vimrc >/dev/null 2>&1; then
   echo "already configured .vimrc"
else
   pause "Press [Enter] to configure .vimrc" true
   cp -n "$PROJECT/includes/.vim_config" "$HOME/$CONFIG"
cat << EOF >> "$HOME/.vimrc"
" source config file
:so ~/$CONFIG/.vim_config
EOF
   [ -f "$HOME/$CONFIG/.vim_config" ] && echo ".vim_config was copied to ~/$CONFIG"
fi

