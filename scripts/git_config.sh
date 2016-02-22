#!/bin/bash
echo "# --------------------------------------------"
echo "# Configure git for $USER_NAME.               "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# configure git
configure_git "$REAL_NAME" "$EMAIL_ADDRESS" "$GIT_EDITOR"

echo
script_name "          done with "
echo "*********************************************"
