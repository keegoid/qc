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

# color terminal prompts
if grep -q "#force_color_prompt=yes" $HOME/.bashrc; then
   pause "Press [Enter] to add terminal color prompts" true
   sed -i.bak -e "s|#force_color_prompt=yes|force_color_prompt=yes|" $HOME/.bashrc
else
   echo "already set color prompts..."
fi

# terminal history lookup
[ -e $HOME/.inputrc ] || printf "" > $HOME/.inputrc
if grep -q "backward-char" $HOME/.inputrc; then
   echo "already added terminal history lookup" true
else
   pause "Press [Enter] to add terminal history lookup..."
# terminal input config file, EOF must not be indented
cat << 'EOF' >> $HOME/.inputrc
# shell command history lookup by matching string
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char
EOF
echo "$HOME/.inputrc was created with:"
cat "$HOME/.inputrc"
fi

