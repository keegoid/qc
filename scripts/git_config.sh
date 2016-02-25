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

# check if git is already configured
if [ -e "$HOME/.gitignore_global" ]; then
   echo "git is already configured."
else
   pause "Press [Enter] to configure git..." true
   # configure git
   configure_git "$REAL_NAME" "$EMAIL_ADDRESS" "$GIT_EDITOR"
fi

