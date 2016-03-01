#!/bin/bash
echo "# --------------------------------------------"
echo "# Configure global git settings.              "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# gitignore_global
if [ -f "$HOME/.gitignore_global" ]; then
   echo "already added .gitignore_global"
else
   pause "Press [Enter] to create .gitignore_global and configure git" true
   cp "$PROJECT/includes/.gitignore_global" "$HOME"
   [ -f "$HOME/.gitignore_global" ] && echo ".gitignore_global was copied to $HOME"
   read -ep "your name for git commit logs: " -i 'Keegan Mullaney' REAL_NAME
   read -ep "your email for git commit logs: " -i 'keeganmullaney@gmail.com' EMAIL_ADDRESS
   read -ep "your preferred text editor for git commits: " -i 'vi' GIT_EDITOR
   configure_git "$REAL_NAME" "$EMAIL_ADDRESS" "$GIT_EDITOR"
fi

