#!/bin/bash
echo "# --------------------------------------------"
echo "# Configure git for $USER_NAME.               "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Company: KM Authorized LLC                  "
echo "# Website: http://kmauthorized.com            "
echo "#                                             "
echo "# MIT: http://kma.mit-license.org             "
echo "# --------------------------------------------"

# configure git
configure_git "$REAL_NAME" "$EMAIL_ADDRESS" "$GIT_EDITOR"

echo
script_name "          done with "
echo "*********************************************"
